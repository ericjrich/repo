# Cubic 2026.08.108 — known-good Ubuntu 24.04 package

Archived package:

`cubic_2026.08.108-release~202608210019~ubuntu24.04.1_all.deb`

This version was retained after Cubic 2026.08.109 failed during
"Copy important files from the original disk image", while 2026.08.108
successfully passed the same operation in the same workflow.

Source: Cubic release PPA for Ubuntu 24.04.

Install/downgrade:

\`\`\`bash
sudo apt install --allow-downgrades ./cubic_2026.08.108-release~202608210019~ubuntu24.04.1_all.deb
sudo apt-mark hold cubic
\`\`\`

Verify:

\`\`\`bash
sha256sum -c SHA256SUMS.txt
\`\`\`
