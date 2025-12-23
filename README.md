# Terraform S3 Bucket Policy Testing with Terraform Test
This repository demonstrates a practical approach to testing Terraform modules against **real AWS behavior** using Terraform’s native `terraform test` framework. The focus is not just on validating that infrastructure can be created, but on understanding how and why AWS rejects certain configurations, and then turning that knowledge into safer, more predictable Terraform code.

Rather than treating AWS errors as something to avoid, this repository treats them as a learning tool. The goal is to observe real failures first, and then progressively harden the module so those same mistakes are caught earlier and more clearly.

## What this repository does
The Terraform configuration in this repository creates a real S3 bucket and attaches a bucket policy generated with `aws_iam_policy_document`. A single variable controls whether the policy is built correctly or incorrectly. This allows the same code path to exercise both a successful apply and a failure scenario.

All tests are executed using `terraform test`, which means Terraform performs real `apply` operations against AWS, evaluates expectations, and then destroys any resources that were created. The tests always run using a temporary and isolated state, so your existing infrastructure is never affected.

## Why test this way
Many infrastructure issues do not appear during `terraform plan`. They only surface during `terraform apply`, once AWS evaluates the request and enforces its own rules. These failures often look obvious in hindsight, but they are easy to miss during development or code review.

By running tests against real AWS, this repository intentionally allows those failures to happen first. Seeing the exact error message returned by AWS provides clarity about the real constraint that was violated, without guessing or relying on incomplete assumptions.

This approach mirrors how infrastructure usually fails in production: not because the code was syntactically invalid, but because it violated a rule enforced by the platform itself.

## From AWS errors to Terraform guardrails
Once an AWS failure is understood, the next step is to harden the module. The learned constraint is encoded as a Terraform `precondition`, which moves the failure from the AWS API into Terraform’s own evaluation phase.

This shift is important. Instead of failing late during an API call, the configuration now fails early, with a clear and intentional error message. The mistake becomes easier to diagnose, faster to fix, and safer to prevent across all future uses of the module.

At this point, the behavior can also be reliably tested.

## Why preconditions are necessary for tests
Terraform’s test framework cannot assert provider or API errors directly. If AWS rejects an operation, the test simply fails and stops, without any way to declare that failure as expected.

By converting known AWS failure modes into `precondition`s, the failure happens inside Terraform itself. This makes it possible to use `expect_failures` in `terraform test` and explicitly assert that the module behaves as intended when given invalid input.

In other words, AWS teaches the rule, Terraform enforces it, and the test locks it in place.

## How the tests work
Each test run executes a real `terraform apply`. One scenario uses valid input and applies successfully. Another scenario intentionally uses invalid input, triggering the module’s precondition and failing in a controlled way.

After each run, Terraform automatically destroys any resources it created. Because the state is temporary and isolated, there is no risk of interfering with existing infrastructure or leaving behind unmanaged resources.

## Running the tests
To run the tests, change into the `terraform/` directory and execute:

```bash
terraform init
terraform test -test-directory="test" -verbose
```

Terraform will create a temporary working directory, run the applies, evaluate expectations, and clean everything up once the tests complete.

## Final takeaway

This repository demonstrates a feedback loop rather than a static test setup. AWS errors are observed first, understood in context, and then codified as Terraform guardrails. `terraform test` is used to ensure those guardrails remain in place over time.

The result is Terraform code that fails earlier, explains itself better, and reflects real AWS behavior rather than assumptions.

<div align="right">
- -

*Made with ❤️ by Santiacmaestre 🚀*

</div>
