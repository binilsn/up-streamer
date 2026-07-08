import js from "@eslint/js";
import globals from "globals";

export default [
    js.configs.recommended,

    {
        ignores: [
            "vendor/",
            "public/",
            "node_modules/",
            "bin/",
            "tmp/",
            "log/",
            "db/",
            "storage/",
            "coverage/",
        ],
    },

    {
        languageOptions: {
            ecmaVersion: 2022,
            sourceType: "module",
            globals: {
                ...globals.browser,
                consumer: "readonly",
                Chart: "readonly",
            },
        },

        rules: {
            // Style — let the codebase keep its existing conventions
            semi: "warn",
            "no-unused-vars": [
                "warn",
                { args: "none", varsIgnorePattern: "^_" },
            ],
            "no-console": "off",
            "prefer-const": "warn",
            "no-var": "error",

            // Possible errors — these are important
            "no-undef": "error",
            "no-duplicate-imports": "error",
        },
    },
];
