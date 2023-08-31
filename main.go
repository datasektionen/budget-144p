package main

import (
	"budgethd/db"
	"context"
	"encoding/json"
	"log"
	"net/http"
)

type Committee struct {
	db.CommitteeModel
	CostCentres []CostCentre `json:"cost_centres"`
}

type CostCentre struct {
	db.CostCentreModel
	Income   int `json:"income"`
	Expenses int `json:"expenses"`
	Internal int `json:"internal"`
}

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

	var result []Committee

	for _, committee := range committees {
		var costCentres []CostCentre
		for _, costCentre := range committee.CostCentres() {
			var income, expenses int
			if committee.Inactive {
				costCentre.RelationsCostCentre.BudgetLines = []db.BudgetLineModel{}
			}

			for _, budgetLine := range costCentre.BudgetLines() {
				income += budgetLine.Income
				expenses += budgetLine.Expenses
			}

			costCentres = append(costCentres, CostCentre{
				CostCentreModel: costCentre,
				Income:          income,
				Expenses:        expenses,
				Internal:        income - expenses})
		}

		result = append(result, Committee{CommitteeModel: committee, CostCentres: costCentres})
	}

	b, err := json.Marshal(result)
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		return
	}

	w.Write(b)
	w.Header().Set("Content-Type", "application/json")
	return
}
