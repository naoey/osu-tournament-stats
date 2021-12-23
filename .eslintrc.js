module.exports = {
  root: true,
  parser: '@typescript-eslint/parser',
  parserOptions: {
    "ecmaVersion": 2020,
    "project": ["tsconfig.json"],
    "sourceType": "module"
  },
  plugins: [
    '@typescript-eslint',
    'import',
    'react',
    'prettier',
    'jest'
  ],
  extends: [
    'airbnb-typescript',
    'prettier',
    'plugin:jest/recommended'
  ],
  "rules": {
    "prettier/prettier": ["error", { "singleQuote": false }],
    "no-console": "off",
    "linebreak-style": 0,
    "no-return-assign": "off",
    "max-len": [
      "error",
      {
        "code": 135,
        "tabWidth": 2,
        "ignoreComments": true,
        "ignoreTrailingComments": true,
        "ignoreUrls": true,
        "ignoreStrings": true,
        "ignoreTemplateLiterals": true,
        "ignoreRegExpLiterals": true
      }
    ],
    "jsx-a11y/label-has-associated-control": "off",
    "react/jsx-one-expression-per-line": "off",
    "react/forbid-prop-types": "off",
    "jsx-a11y/no-static-element-interactions": "off",
    "jsx-a11y/click-events-have-key-events": "off",
    "no-plusplus": "off",
    "no-continue": "off",
    "react/react-in-jsx-scope": "off",
    "react/jsx-props-no-spreading": "off",
    "react/require-default-props": "off",
    "camelcase": "off",
    "arrow-parens": "off",
    "no-fallthrough": "off",
    "no-restricted-syntax": "off",
    "padding-line-between-statements": ["error",
      { "blankLine": "always", "prev": "*", "next": "return" },
      { "blankLine": "always", "prev": ["const", "let", "var"], "next": "*" },
      { "blankLine": "never", "prev": "singleline-const", "next": "singleline-const" },
      { "blankLine": "never", "prev": "singleline-let", "next": "singleline-let" },
      { "blankLine": "never", "prev": "singleline-var", "next": "singleline-var" },
      { "blankLine": "always", "prev": "multiline-const", "next": "multiline-const" },
      { "blankLine": "always", "prev": "multiline-let", "next": "multiline-let" },
      { "blankLine": "always", "prev": "multiline-var", "next": "multiline-var" },
      { "blankLine": "always", "prev": "break", "next": ["case", "default"] },
      { "blankLine": "always", "prev": "block-like", "next": "*" },
      { "blankLine": "always", "prev": "*", "next": "block-like" }
    ],

    "react-hooks/exhaustive-deps": "off",
    "react/function-component-definition": ["error", { "namedComponents": "function-declaration" }],
    "react/no-multi-comp": "error",

    "import/order": ["error", {
      "newlines-between": "always",
      "warnOnUnassignedImports": true,
      "alphabetize": { "order": "asc", "caseInsensitive": false },
      "pathGroups": [{
        "pattern": "{.,..}/**/*.scss",
        "group": "sibling",
        "position": "after"
      }]
    }],

    "jest/no-done-callback": "off"
  }
};
