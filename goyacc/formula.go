package goyacc

import (
	"fmt"
	"strings"
)

var opToANDOR = map[string]string{
	orOp:  "OR",
	andOp: "AND",
}

// Formula represents a formula for labels
type Formula struct {
	ast *ast
}

// FromString creates a new instance of formula from a string
func FromString(str string) (*Formula, error) {
	src := strings.NewReader(str)
	ast, err := parse("formula", src)
	if err != nil {
		return nil, err
	}

	return &Formula{
		ast: ast,
	}, nil
}

// postgresQuery traverses an AST in an LRV fashion and creates a SQL query
func postgresQuery(n *node, table, field string) string {
	// Label (leaf node)
	if n.typ == label {
		return fmt.Sprintf(`EXISTS (SELECT 1 FROM %s WHERE %s LIKE '%%%s%%')`, table, field, n.val)
	}

	// Op node
	if n.typ == op {
		leftQuery := postgresQuery(n.left, table, field)
		rightQuery := postgresQuery(n.right, table, field)
		return fmt.Sprintf(`(%s %s %s)`, leftQuery, opToANDOR[n.val], rightQuery)
	}

	return ""
}

// PostgresQuery constructs a PostgreSQL query for the formula
func (f *Formula) PostgresQuery(table, field string) string {
	where := postgresQuery(f.ast.root, table, field)
	query := fmt.Sprintf(`SELECT * FROM %s WHERE (%s)`, table, where)

	return query
}
