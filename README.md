# Terraform Module Testing

This is a custom GitHub Action that generates GitHub Actions testing configurations for Terraform modules. We use it extensively for testing both our internal and [publicly-available](https://registry.terraform.io/namespaces/Invicton-Labs) Terraform modules.

## Usage

This is an example of how you might configure a GitHub workflow to use this Action.
```
name: "Build"

on: [push, pull_request]

jobs:

  # This job generates the testing matrix
  Matrix:
    runs-on: ubuntu-latest
    steps:
      - name: Generate Matrix
        id: matrix
        uses: Invicton-Labs/terraform-module-testing-configuration/matrix@main
        with:
          # The minimum Terraform version to test with. It will test with the first patch
          # version of each major/minor version that is at least as high as this value,
          # e.g. for this example, every version matching X.Y.0 where X > 0 and Y > 13
          minimum_tf_version: '0.13.0'

    # Output the generated matrix for the testing job
    outputs:
      strategy: ${{ steps.matrix.outputs.strategy }}

  # Run the actual tests
  Test:
    needs: [Matrix]
    # Load the strategy, including the matrix and fail-fast parameter,
    # from the output of the previous job.
    strategy: ${{ fromJSON(needs.Matrix.outputs.strategy)}}
    # The matrix includes values for runner image and container
    runs-on: ${{ matrix.runs-on }}
    container: ${{ matrix.container }}

    # Run the tests using a different subdirectory of the same custom Action
    steps:
      - name: Run Tests
        id: tests
        uses: Invicton-Labs/terraform-module-testing-configuration/test@main
        with:
          testing_path: tester

  # This job just waits for all other jobs to pass. We have it here
  # so our GitHub branch protection rule can reference a single job, 
  # instead of needing to list every matrix value of every job above.
  Passed:
    runs-on: ubuntu-latest
    needs: [Test]
    steps:
    - name: Mark tests as passed
      run: echo "🎉"
```