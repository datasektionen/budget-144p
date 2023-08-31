import { BudgetLine, Committee, CostCentre } from "@prisma/client";
import prisma from "../db";

import express from "express";
const router = express.Router();

function computeResults(
  committee: Committee,
  costCentre: CostCentre & {
    budget_lines: BudgetLine[];
  }
): CostCentre & {
  budget_lines: BudgetLine[];
  income: number;
  expenses: number;
  internal: number;
} {
  let income = 0;
  let expenses = 0;
  if (committee.inactive) {
    costCentre.budget_lines = [];
  }

  for (let k = 0; k < costCentre.budget_lines.length; k++) {
    const budgetLine = costCentre.budget_lines[k];
    income += budgetLine.income;
    expenses += budgetLine.expenses;
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
    include: {
      cost_centres: {
        include: {
          budget_lines: {
            where: {
              valid_from: { lte: new Date() },
              valid_to: { gt: new Date() },
              AND: [
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
