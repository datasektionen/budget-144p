package main

import (
	"budgethd/db"
	"context"
	"log"
	"net/http"

	jsoniter "github.com/json-iterator/go"
)

var client *db.PrismaClient

func main() {

	client = db.NewClient()
	if err := client.Prisma.Connect(); err != nil {
		panic(err)
	}

	defer func() {
		if err := client.Prisma.Disconnect(); err != nil {
			panic(err)
		}
	}()

	http.HandleFunc("/api/committees", getAllCommittees)

	log.Fatal(http.ListenAndServe(":3000", nil))
}

func getAllCommittees(w http.ResponseWriter, r *http.Request) {
	ctx := context.Background()

	committees, err := client.Committee.FindMany().With(db.Committee.CostCentres.Fetch().With(db.CostCentre.BudgetLines.Fetch())).Exec(ctx)
	if err != nil {
		panic(err)
	}

	for i, committee := range committees {
		for j, costCentre := range committee.CostCentres() {
			var income, expenses int
			if committee.Inactive {
				costCentre.RelationsCostCentre.BudgetLines = []db.BudgetLineModel{}
			}

			for _, budgetLine := range costCentre.BudgetLines() {
				income += budgetLine.Income
				expenses += budgetLine.Expenses
			}

			committees[i].CostCentres()[j].Income = income
			committees[i].CostCentres()[j].Expenses = expenses
			committees[i].CostCentres()[j].Internal = income - expenses
		}
	}

	b, err := jsoniter.Marshal(committees)
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		return
	}

	w.Write(b)
	w.Header().Set("Content-Type", "application/json")
	return
}
