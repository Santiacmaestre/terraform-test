# Terraform S3 Bucket Policy Testing with `terraform test`

This repository shows a **practical and realistic way to test Terraform modules against real AWS behavior**, using Terraform’s native **`terraform test`** framework.

The goal is not only to test “happy paths”, but to **learn from real AWS errors**, then **harden the module** so those mistakes are caught earlier and more deterministically.

## What this repository is about

This repo provisions:

- A real **S3 bucket**
- A **bucket policy** generated with `aws_iam_policy_document`
- A toggleable input that makes the policy **correct or incorrect**
- Tests that run **real `terraform apply` operations** against AWS

The focus is on a very common class of issues:

> Configurations that plan successfully, but fail at apply time due to subtle AWS constraints.

## Testing philosophy

### 1. Start by relying on AWS errors

This repository **does rely on AWS errors directly at first**.

That is intentional.

Many real-world mistakes:
- Do not show up in `terraform plan`
- Look fine in code review
- Only fail once AWS evaluates the request

Examples:
- Using a bucket ARN instead of an object ARN (`bucket` vs `bucket/*`)
- Policies that are syntactically valid but semantically wrong
- Security controls enforced at the account or service level

The first time these issues appear, **AWS is the source of truth**.

Running tests against real AWS lets you:
- See the exact error returned by AWS
- Understand the real constraint being violated
- Avoid guessing or over-validating too early

### 2. Harden the module with preconditions

Once an AWS failure is understood, the module is **hardened**:

- The learned constraint is encoded as a `precondition`
- The failure moves from AWS → Terraform
- The error becomes deterministic and intentional
- The mistake is caught **earlier**, before the API call

This turns:
- Late, surprising apply-time failures  
into  
- Early, clear, actionable feedback

### 3. Why preconditions are required for tests

Terraform’s test framework **cannot assert provider or API errors directly**.

If AWS rejects an operation:
- The test fails immediately
- The failure cannot be marked as “expected”

By encoding known AWS failure modes as `precondition`s:
- The failure happens inside Terraform
- `terraform test` can assert it with `expect_failures`
- Tests become reliable and repeatable
- Module behavior is documented in code

## How the tests work

The tests run two scenarios:

1. **Valid input**
   - The bucket and policy are created successfully
   - The apply passes
   - Resources are destroyed after the test

2. **Invalid input**
   - The policy is intentionally wrong
   - The module’s precondition fails
   - The failure is expected and asserted

Both scenarios run against **real AWS**, using a **temporary, isolated state** created by `terraform test`.

Your existing infrastructure state is never touched.

## Running the tests

From inside the `terraform/` directory:

```bash
terraform init
terraform test -test-directory="test" -verbose
````

What Terraform does under the hood:

1. Creates a temporary working directory
2. Uses a fresh, isolated state
3. Runs real `terraform apply`
4. Evaluates test expectations
5. Runs `terraform destroy`
6. Cleans up the temporary state

## Mental model

Think of this repository as demonstrating a loop:

```text
AWS apply error
        ↓
Understand the real constraint
        ↓
Add Terraform precondition
        ↓
Test it explicitly
        ↓
Prevent the mistake everywhere
```

## Key takeaway

* AWS errors are **not avoided**
* They are **observed, understood, and codified**
* `terraform test` is used to lock that knowledge in place

The result is infrastructure code that:

* Fails earlier
* Fails clearer
* Is safer to reuse
* Encodes real AWS behavior, not assumptions
