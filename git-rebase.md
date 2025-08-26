# Git rebase workflow

## **Step 0: Start from main**

Make sure your local `main` is up to date:

```bash
git checkout main
git pull origin main
```

## **Step 1: Create a feature branch**

```bash
git checkout -b feature_branch
```

* Do your work, make commits as needed.
* Commit messages should be clear, e.g., `feat: add deploy-s3 workflow`.

## **Step 2: Rebase onto the latest main**

When you’re ready to update your branch with changes from `main`:

```bash
git fetch origin
git rebase origin/main
```

* Git may pause if there are **conflicts**.

## **Step 3: Resolve conflicts**

1. Open conflicting files, fix the conflicts.
2. Stage the resolved files:

```bash
git add <file1> <file2>  # or git add .
```

3. Continue the rebase:

```bash
git rebase --continue
```

* Repeat until all conflicts are resolved.

## **Step 4: Verify your branch**

Check your history:

```bash
git log --oneline --graph --all
```

* Your branch should now be “linear” on top of `main`.
* Your commits have **new hashes** (`D'`, `E'`) because rebase rewrites history.

## **Step 5: Push your branch to remote**

Because the history changed, you **must force push**:

```bash
git push origin feature_branch --force-with-lease
```

* `--force-with-lease` is safer than `--force` — it ensures you don’t overwrite someone else’s work on the branch.

## **Step 6: Open a PR**

1. Go to GitHub.
2. Open a pull request from `feature_branch` → `main`.
3. You can choose:

   * **Rebase and merge** → keeps history linear.
   * **Squash and merge** → combines all commits into one.
   * **Create merge commit** → keeps all commits and adds a merge commit.

## **Step 7: After merge**

1. Delete the feature branch (optional).
2. Pull latest main locally to stay updated:

```bash
git checkout main
git pull origin main
```

### ✅ **Tips / Best Practices**

* Always **rebase interactively** before merging if you want to clean up commit history:

```bash
git rebase -i origin/main
```

* Use `--force-with-lease` instead of plain `--force` whenever pushing rebased branches.
* Avoid rebasing **shared branches** that others are working on — only rebase **your feature branch**.
* Use descriptive commit messages (feat/fix/chore style).