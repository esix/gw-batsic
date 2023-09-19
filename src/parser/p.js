
const ROOT = 'Root'; // Artificial start non-terminal
const EPSILON = 'ε';
const EOL = 'EOL';


function union(set1, set2) {
  let u = new Set(set1);
  for (let elt of set2) {
      u.add(elt);
  }
  return u;
}

// Given a map m from keys to sets of elements, add elt to m[key]
// if elt was not already in m[key], set the m.changed flag
function addToSetMap(m, key, elt) {
  if (!m[key].has(elt)) {
    m[key].add(elt);
    m.changed = true;
  }
}

function computeNullable(grammar) {
  console.log("Computing nullable...");
  var nullable = new Set();
  var fixpoint = false;
  var iteration = 0;
  while (!fixpoint) {
    fixpoint = true;
    for (let rule of grammar.rules) {
      // RHS is nullable if every symbol in the RHS is nullable
      if (rule.slice(1).every(x => nullable.has(x))) {
        if (!(nullable.has(rule[0]))) {
          nullable.add(rule[0]);
          fixpoint = false;
        }
      }
    }
    console.log("  Nullable table @ iteration " + (++iteration));
    console.log("    " + Array.from(nullable).join(", "));
  }
  console.log("Nullable=", nullable);
  return nullable;
}

// compute first of a right-hand-side of a production (i.e., a
// sequence of terminals and noterminals).
function firstRhs(rhs, nullable, first) {
  // find longest nullable prefix
  var end = rhs.findIndex((sym) => !(nullable.has(sym)));
  if (end == -1) {
    end = rhs.length;
  }
  return rhs.slice(0, end + 1).map((sym) => first[sym]).reduce(union, new Set());
}

function computeFirst(grammar, nullable) {
  console.log("Computing first...", grammar.terminals, grammar.nonterminals);
  let first = {};

  // To simplify first/follow logic, define first(t) = {t} for any terminal t
  for (let terminal of grammar.terminals) {
    first[terminal] = new Set([terminal]);
  }
  for (let nonterminal of grammar.nonterminals) {
    first[nonterminal] = new Set();
  }

  first.changed = true;
  var iteration = 0;
  while (first.changed) {
    first.changed = false;
    for (let rule of grammar.rules) {
      firstRhs(rule.slice(1), nullable, first).forEach((terminal) =>
          addToSetMap(first, rule[0], terminal));
    }
    console.log("  First table @ iteration " + (++iteration));
    console.log(stringOfSetMap(first, 4));
  }
  console.log("Done!");

  return first;
}

function computeFollow(grammar, nullable, first) {
  console.log("Computing follow...");

  let follow = {};
  for (nonterminal of grammar.nonterminals) {
    follow[nonterminal] = new Set();
  }
  follow.changed = true;
  let iteration = 0;

  while (follow.changed) {
    follow.changed = false;

    for (rule of grammar.rules) {
      // invariant: rule_follow is the follow set for position i of rule.rhs
      var rule_follow = follow[rule[0]];
      for (let i = rule.slice(1).length - 1; i >= 0; i--) {
        if (grammar.nonterminals.has(rule.slice(1)[i])) {
          rule_follow.forEach(terminal => addToSetMap(follow, rule.slice(1)[i], terminal));
        }
        if (nullable.has(rule.slice(1)[i])) {
          rule_follow = union(rule_follow, first[rule.slice(1)[i]]);
        } else {
          rule_follow = first[rule.slice(1)[i]];
        }
      }
    }
    console.log("  Follow table @ iteration " + (++iteration));
    console.log(stringOfSetMap(follow, 4));
  }
  console.log("Done!");
  return follow;
}

function computeTransition(grammar, nullable, first, follow) {
  let transition = {};
  for (let n of grammar.nonterminals) {
      transition[n] = {};
      for (t of grammar.terminals) {
          transition[n][t] = [];
      }
  }
  for (let rule of grammar.rules) {
    for (let a of firstRhs(rule.slice(1), nullable, first)) {
      transition[rule[0]][a].push(rule);
    }

    if (rule.slice(1).every(x => nullable.has(x))) {
      for (a of follow[rule[0]]) {
          transition[rule[0]][a].push(rule);
      }
    }
  }
  return transition;
}

// compute LL(1) tables
function computeTables(grammar) {
  const nullable = computeNullable(grammar);
  const first = computeFirst(grammar, nullable);
  const follow = computeFollow(grammar, nullable, first);
  const transition = computeTransition(grammar, nullable, first, follow);
  return {nullable, first, follow, transition};
}


function initGrammar(bnf) {
  let rules = [];
  let nonterminals = new Set([ROOT]);

  for (let rule of bnf.split('\n')) {
    if (rule.startsWith('#')) continue;
    if (!rule) continue;
    console.log(rule);
    const split_rule = rule.split('::=');
    if (split_rule.length == 2) {
      const lhs = split_rule[0].trim();
      const rhs = split_rule[1].trim().split(/\s+/).filter((x) => !(x == EPSILON));
      rules.push([lhs, ...rhs]);
      nonterminals.add(lhs);
    }
  }

  const terminals = new Set([EOL]);
  for (let rule of rules) {
    rule.slice(1).forEach(function (symbol) {
      if (!(nonterminals.has(symbol))) {
        terminals.add(symbol);
      }
    });
  }

  // Use the left hand side of the first rule as starting nonterminal
  let start = rules[0][0];

  rules.push([ROOT, start, EOL]);

  let grammar = {
    rules,
    terminals,
    nonterminals,
    start,
  };

  return grammar;
}

function stringOfSetMap(m, indent) {
  let s = "";
  for (let key in m) {
    if (key != "changed") {
      s += " ".repeat(indent) + key + " -> " + Array.from(m[key]).join(", ") + "\n";
    }
  }
  return s;
}


function displayTables(grammar, tables) {
  function stringOfRule(rule) {
    if (rule.slice(1).length == 0) {
      return rule[0] + " ::= ε";
    } else {
      return rule[0] + " ::= " + rule.slice(1).join(' ');
    }
  }

  const {nullable, first, follow, transition} = tables;
  let t1 = [];
  for (let nonterminal of grammar.nonterminals) {
    t1.push({
      "Nonterminal": nonterminal,
      "Nullable?": nullable.has(nonterminal) ? "v" : "x",
      "First": Array.from(first[nonterminal]).join(", "),
      "Follow": Array.from(follow[nonterminal]).join(", ")
    })
  }
  console.table(t1);

  let t2 = [];
  let conflict = false;

  for (let nonterminal of grammar.nonterminals) {
    let entry = {};
    entry[''] = nonterminal;

    for (var terminal of grammar.terminals) {
      var contents = transition[nonterminal][terminal]
          .map(stringOfRule)
          .join("\n");

      if (transition[nonterminal][terminal].length > 1) {
        entry[terminal] = "!!!" + contents + "!!!";
        conflict = true;
      } else {
        entry[terminal] = contents;
      }
  }
    t2.push(entry);
  }
  console.table(t2);

  if (conflict) {
    console.log("Conflict detected. Grammar is not LL(1)!");
  }
}


/**
 * A number, or a string containing a number.
 * @typedef {{label: string, children: Array.<Node>}} Node
 */


function parse(prg, grammar, tables) {
  /** @type Node  */
  let root = {
    label: grammar.start,
    children: [],
  }

  /** @type Array.<string> */
  let input = prg.trim().split(/\s/).concat([EOL]);
  /** @type Array.<string> */
  let stack = [EOL, grammar.start];
    /** @type number */
  let position = 0;
  let parents = [root];

  while (position < input.length) {
    const top = stack.pop();
    const next = input[position];

    if (grammar.terminals.has(top)) {
      // If top of the stack matches next input character, consume the input
      if (next == top) {
        position++;
        parents.pop();
        console.log('Match ', next);
      } else {
        throw new Error("Expected " + top + ", got " + next);
      }
    } else if (next in tables.transition[top]) {
      let rule = tables.transition[top][next][0];
      if (rule == undefined) {
        throw new Error("Syntax error when trying to expand elements at the top of the stack:\nNo valid transition from a nonterminal \"" + top + '\" with look ahead symbol \"' + next + "\"");
      }

      stack.push(...[].concat(rule.slice(1)).reverse());

      /* Display code ********************************************************/
      var p = parents.pop();
      childnodes = [];
      if (rule.slice(1).length == 0) {
        p.children.push({
          label: EPSILON,
          children: [],
        });
      } else {
        for (var i of rule.slice(1)) {
          var node = {
            label: i,
            children: [],
          }
          p.children.push(node);
          childnodes.push(node);
        }
      }
      parents = parents.concat(childnodes.reverse());

    } else {
      throw new Error("failure");
    }
  }

  return root;
}


const bnf = require('fs').readFileSync('./grammar.bnf', { encoding: 'utf8', flag: 'r' });



const grammar = initGrammar(bnf);
console.log(grammar);

const tables = computeTables(grammar);

displayTables(grammar, tables);




let root = parse('id + id', grammar, tables)


const drawTree = (item, l = 0) => {
  console.log(''.padStart(l), item.label);
  item.children.map(c => drawTree(c, l + 2))
}

drawTree(root);
