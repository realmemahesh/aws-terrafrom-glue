@ Quick cheat sheet

    Revert cloud to code: terraform apply

    Accept cloud into state: terraform apply -refresh-only

    Adopt existing resource: terraform import <addr> <id>

    Stop managing resource: terraform state rm <addr>

    Stop managing certain fields: lifecycle.ignore_changes = [...]

@ terraform apply -parallelism=5
    This limits the maximum number of concurrent operations to 5.

    Terraform will still respect dependencies (it never runs resources out of order).

    But at most 5 independent resources will be created/updated at the same time.

    Others wait in a queue until a “slot” is free.

