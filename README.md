# 🔥 action-hotfix-handler

A secure and reusable GitHub workflow for handling `hotfix/*` pull requests:

- Ensures hotfix is based on default branch (`main` or `master`)
- Verifies linear branch promotion chain (e.g., `main → staging → qa`)
- Performs dry-run merge on all branches before real merge
- Executes real merge and optional tagging only if safe

## ✅ Usage

In your consuming repo:

```yaml
jobs:
  hotfix:
    uses: b3bb0/action-hotfix-handler/.github/workflows/final.yml@v1
    with:
      pr_number: ${{ github.event.pull_request.number }}
      pr_title: ${{ github.event.pull_request.title }}
      source_branch: ${{ github.head_ref }}
      branches: staging,qa,dev
```

## 📋 Inputs

| Name           | Required | Description                                 |
|----------------|----------|---------------------------------------------|
| pr_number      | ✅        | Pull request number                         |
| pr_title       | ✅        | Title used in merge commit                  |
| source_branch  | ✅        | The hotfix branch (e.g., `hotfix/bug`)      |
| branches       | ✅        | Comma-separated downstream branches    **`by stream order`** |

---
