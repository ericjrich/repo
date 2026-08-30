# Regression in 2026.08.109: “Unable to copy files from the original disk image”; 2026.08.108 works

## Describe the bug

Cubic 2026.08.109 fails during creation of a fresh project at the stage:

```text
Copy important files from the original disk image.
Error: Unable to copy files from the original disk image.
```

The original ISO is successfully analyzed first, then the copy stage fails.

I reproduced the failure twice with fresh Cubic projects.

Downgrading only Cubic from 2026.08.109 to 2026.08.108 fixed the problem. Using the same host, same source ISO, and same workflow, 2026.08.108 successfully passed the copy/extraction stage and completed the customized ISO build.

This appears to be a regression introduced in 2026.08.109.

## To reproduce

1. On Linux Mint 22.3, install/update Cubic to:
   `2026.08.109-release~202608290311~ubuntu24.04.1`
2. Start Cubic and create a new project from the same Linux Mint 22.3 source ISO.
3. Continue to the initial extraction/customization preparation stage.
4. Cubic successfully analyzes the original disk image.
5. Cubic then fails at:
   `Copy important files from the original disk image.`
   `Error: Unable to copy files from the original disk image.`
6. Downgrade Cubic to:
   `2026.08.108-release~202608210019~ubuntu24.04.1`
7. Retry with a fresh project using the same source ISO and workflow.
8. The copy/extraction stage succeeds and the ISO build completes.

## Expected behavior

Cubic should copy the required files from the original disk image and continue to extract the Linux filesystem, as it does in 2026.08.108.

## Actual behavior

Cubic 2026.08.109 stops at the copy stage with:

```text
Error: Unable to copy files from the original disk image.
```

## OS information

- Host OS: Linux Mint 22.3
- Ubuntu base: 24.04 (Noble)

## Cubic information

### Failing version

`2026.08.109-release~202608290311~ubuntu24.04.1`

### Known-good version

`2026.08.108-release~202608210019~ubuntu24.04.1`

## Screenshot

![Cubic 2026.08.109 copy-stage error](https://raw.githubusercontent.com/ericjrich/repo/main/issue-assets/cubic-109/cubic-109-copy-error.png)

## Additional notes

- Failure reproduced twice on 2026.08.109.
- The source ISO was readable and successfully analyzed by Cubic before the failure.
- No custom payload or chroot modification had been applied yet when the failure occurred.
- 2026.08.108 was tested immediately afterward and successfully completed the same copy/extraction workflow and subsequent ISO build.
