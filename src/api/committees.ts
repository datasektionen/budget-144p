import { BudgetLine, Committee, CostCentre } from "@prisma/client";
import prisma from "../db";

import express from "express";
const router = express.Router();

function computeResults(committee: any, costCentre: any) {
  let income = 0;
  let expenses = 0;
  if (committee.inactive) {
    costCentre.budget_lines = [];
  }

  for (let k = 0; k < costCentre.budget_lines.length; k++) {
    const budgetLine = costCentre.budget_lines[k];
    income += budgetLine.income;
    expenses += budgetLine.expenses;
    costCentre.budget_lines[k].balance =
      budgetLine.income - budgetLine.expenses;
  }

  return {
    ...costCentre,
    income,
    expenses,
    internal: income - expenses,
  };
}

router.get("/", async (req, res) => {
  let committees = await prisma.committee.findMany({
    select: {
      id: true,
      name: true,
      inactive: true,
      type: true,
      cost_centres: {
        select: {
          id: true,
          name: true,
          speedledger_id: true,
          repetitions: true,
          committee_id: true,
          budget_lines: {
            select: {
              id: true,
              name: true,
              cost_centre_id: true,
              income: true,
              expenses: true,
              parent: true,
              accounts: true,
              suggestion_id: true,
              type: true,
              valid_from: true,
              valid_to: true,
            },
            where: {
              OR: [
                {
                  valid_from: { lte: new Date() },
                  valid_to: { gt: new Date() },
                  OR: [
                    {
                      suggestion: {
                        implemented_at: { not: null },
                      },
                    },
                    {
                      NOT: {
                        follow_ups: undefined,
                      },
                    },
                  ],
                },
                { suggestion_id: -1 },
              ],
            },
          },
        },
      },
    },
  });

  for (let i = 0; i < committees.length; i++) {
    let committee = committees[i];
    for (let j = 0; j < committee.cost_centres.length; j++) {
      const contCentre = committee.cost_centres[j];
      committees[i].cost_centres[j] = computeResults(committee, contCentre);
    }
  }

  res.json(committees);
});

export default router;
