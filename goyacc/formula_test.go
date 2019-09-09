package goyacc

import (
	"errors"
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestFromString(t *testing.T) {
	tests := []struct {
		str             string
		expectedError   error
		expectedFormula *Formula
	}{
		{
			str:             "label1",
			expectedError:   errors.New("syntax error"),
			expectedFormula: nil,
		},
		{
			str:           "(label1)",
			expectedError: nil,
			expectedFormula: &Formula{
				ast: &ast{
					root: &node{
						typ: label,
						val: "label1",
					},
				},
			},
		},
		{
			str:           "(label1,label2)",
			expectedError: nil,
			expectedFormula: &Formula{
				ast: &ast{
					root: &node{
						typ: op,
						val: andOp,
						left: &node{
							typ: label,
							val: "label1",
						},
						right: &node{
							typ: label,
							val: "label2",
						},
					},
				},
			},
		},
		{
			str:           "(label1;label2)",
			expectedError: nil,
			expectedFormula: &Formula{
				ast: &ast{
					root: &node{
						typ: op,
						val: orOp,
						left: &node{
							typ: label,
							val: "label1",
						},
						right: &node{
							typ: label,
							val: "label2",
						},
					},
				},
			},
		},
	}

	for _, tc := range tests {
		f, err := FromString(tc.str)

		assert.Equal(t, tc.expectedError, err)
		assert.Equal(t, tc.expectedFormula, f)
	}
}

func TestBuildPostgresQuery(t *testing.T) {
	tests := []struct {
		str           string
		table         string
		field         string
		expectedQuery string
	}{
		{
			str:           "(label1)",
			table:         "products",
			field:         "tags",
			expectedQuery: "SELECT * FROM products WHERE (EXISTS (SELECT 1 FROM products WHERE tags LIKE '%label1%'))",
		},
		{
			str:           "(label-1)",
			table:         "products",
			field:         "tags",
			expectedQuery: "SELECT * FROM products WHERE (EXISTS (SELECT 1 FROM products WHERE tags LIKE '%label-1%'))",
		},
		{
			str:           "(label1,label2)",
			table:         "products",
			field:         "tags",
			expectedQuery: "SELECT * FROM products WHERE ((EXISTS (SELECT 1 FROM products WHERE tags LIKE '%label1%') AND EXISTS (SELECT 1 FROM products WHERE tags LIKE '%label2%')))",
		},
		{
			str:           "(label1;label2)",
			table:         "products",
			field:         "tags",
			expectedQuery: "SELECT * FROM products WHERE ((EXISTS (SELECT 1 FROM products WHERE tags LIKE '%label1%') OR EXISTS (SELECT 1 FROM products WHERE tags LIKE '%label2%')))",
		},
	}

	for _, tc := range tests {
		f, err := FromString(tc.str)
		assert.NoError(t, err)

		query := f.PostgresQuery(tc.table, tc.field)
		assert.Equal(t, tc.expectedQuery, query)
	}
}
