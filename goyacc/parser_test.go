package goyacc

import (
	"errors"
	"strings"
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestParse(t *testing.T) {
	tests := []struct {
		name          string
		formula       string
		expectedError error
		expectedAST   *ast
	}{
		{
			name:          "e1",
			formula:       "",
			expectedError: errors.New("syntax error"),
			expectedAST:   nil,
		},
		{
			name:          "e2",
			formula:       "label1",
			expectedError: errors.New("syntax error"),
			expectedAST:   nil,
		},
		{
			name:          "e3",
			formula:       "(label1",
			expectedError: errors.New("syntax error"),
			expectedAST:   nil,
		},
		{
			name:          "f1",
			formula:       "(label1)",
			expectedError: nil,
			expectedAST: &ast{
				root: &node{
					typ: label,
					val: "label1",
				},
			},
		},
		{
			name:          "f2",
			formula:       "(label-1)",
			expectedError: nil,
			expectedAST: &ast{
				root: &node{
					typ: label,
					val: "label-1",
				},
			},
		},
		{
			name:          "f3",
			formula:       "(label-a-1)",
			expectedError: nil,
			expectedAST: &ast{
				root: &node{
					typ: label,
					val: "label-a-1",
				},
			},
		},
		{
			name:          "f4",
			formula:       "((label1))",
			expectedError: nil,
			expectedAST: &ast{
				root: &node{
					typ: label,
					val: "label1",
				},
			},
		},
		{
			name:          "f5",
			formula:       "(label1,label2)",
			expectedError: nil,
			expectedAST: &ast{
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
		{
			name:          "f6",
			formula:       "(label1;label2)",
			expectedError: nil,
			expectedAST: &ast{
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
		{
			name:          "f7",
			formula:       "(label1,label2,label3)",
			expectedError: nil,
			expectedAST: &ast{
				root: &node{
					typ: op,
					val: andOp,
					left: &node{
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
					right: &node{
						typ: label,
						val: "label3",
					},
				},
			},
		},
		{
			name:          "f8",
			formula:       "(label1;label2;label3)",
			expectedError: nil,
			expectedAST: &ast{
				root: &node{
					typ: op,
					val: orOp,
					left: &node{
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
					right: &node{
						typ: label,
						val: "label3",
					},
				},
			},
		},
		{
			name:          "f9",
			formula:       "(label1,label2;label3)",
			expectedError: nil,
			expectedAST: &ast{
				root: &node{
					typ: op,
					val: orOp,
					left: &node{
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
					right: &node{
						typ: label,
						val: "label3",
					},
				},
			},
		},
		{
			name:          "f10",
			formula:       "(label1;label2,label3)",
			expectedError: nil,
			expectedAST: &ast{
				root: &node{
					typ: op,
					val: andOp,
					left: &node{
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
					right: &node{
						typ: label,
						val: "label3",
					},
				},
			},
		},
		{
			name:          "f11",
			formula:       "(label1,(label2;label3))",
			expectedError: nil,
			expectedAST: &ast{
				root: &node{
					typ: op,
					val: andOp,
					left: &node{
						typ: label,
						val: "label1",
					},
					right: &node{
						typ: op,
						val: orOp,
						left: &node{
							typ: label,
							val: "label2",
						},
						right: &node{
							typ: label,
							val: "label3",
						},
					},
				},
			},
		},
		{
			name:          "f12",
			formula:       "(label1;(label2,label3))",
			expectedError: nil,
			expectedAST: &ast{
				root: &node{
					typ: op,
					val: orOp,
					left: &node{
						typ: label,
						val: "label1",
					},
					right: &node{
						typ: op,
						val: andOp,
						left: &node{
							typ: label,
							val: "label2",
						},
						right: &node{
							typ: label,
							val: "label3",
						},
					},
				},
			},
		},
		{
			name:          "f13",
			formula:       "(label1,(label2;label3),label4)",
			expectedError: nil,
			expectedAST: &ast{
				root: &node{
					typ: op,
					val: andOp,
					left: &node{
						typ: op,
						val: andOp,
						left: &node{
							typ: label,
							val: "label1",
						},
						right: &node{
							typ: op,
							val: orOp,
							left: &node{
								typ: label,
								val: "label2",
							},
							right: &node{
								typ: label,
								val: "label3",
							},
						},
					},
					right: &node{
						typ: label,
						val: "label4",
					},
				},
			},
		},
		{
			name:          "f14",
			formula:       "(label1;(label2,label3);label4)",
			expectedError: nil,
			expectedAST: &ast{
				root: &node{
					typ: op,
					val: orOp,
					left: &node{
						typ: op,
						val: orOp,
						left: &node{
							typ: label,
							val: "label1",
						},
						right: &node{
							typ: op,
							val: andOp,
							left: &node{
								typ: label,
								val: "label2",
							},
							right: &node{
								typ: label,
								val: "label3",
							},
						},
					},
					right: &node{
						typ: label,
						val: "label4",
					},
				},
			},
		},
		{
			name:          "f15",
			formula:       "((label1,label2);(label3,label4))",
			expectedError: nil,
			expectedAST: &ast{
				root: &node{
					typ: op,
					val: orOp,
					left: &node{
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
					right: &node{
						typ: op,
						val: andOp,
						left: &node{
							typ: label,
							val: "label3",
						},
						right: &node{
							typ: label,
							val: "label4",
						},
					},
				},
			},
		},
		{
			name:          "f16",
			formula:       "((label1;label2),(label3;label4))",
			expectedError: nil,
			expectedAST: &ast{
				root: &node{
					typ: op,
					val: andOp,
					left: &node{
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
					right: &node{
						typ: op,
						val: orOp,
						left: &node{
							typ: label,
							val: "label3",
						},
						right: &node{
							typ: label,
							val: "label4",
						},
					},
				},
			},
		},
	}

	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			src := strings.NewReader(tc.formula)
			ast, err := parse(tc.name, src)
			assert.Equal(t, tc.expectedError, err)
			assert.Equal(t, tc.expectedAST, ast)
		})
	}
}
