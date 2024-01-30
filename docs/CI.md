# Continuous Integration

> ## All branches

1. Lint: Pronto

    * rubocop
    * brakeman
    * bundler_audit
    * erb_lint
    * flay
    * reek
    * fasterer

2. Test:

    * Bundle install
    * npm install
    * Instanciation des services redis et postgres
    * rails db:migrate
    * rails t

> ## Master

Build image and push to registry.
Deploy to pre-production environment.

> ## Tags

Build image and push to registry.
Deploy to production environment.
