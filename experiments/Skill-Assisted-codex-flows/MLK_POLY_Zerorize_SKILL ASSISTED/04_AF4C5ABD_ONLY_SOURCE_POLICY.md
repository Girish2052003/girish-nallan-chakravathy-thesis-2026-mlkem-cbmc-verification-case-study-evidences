# AF4C5ABD-only source policy

The sole authoritative source is:

```text
af4c5abdd5958bdc65a03cd5ee86708264f93304
```

with Git tree:

```text
54805daff6a91a010c05467ea678117c42a71559
```

The package contains no accepted fallback commit, compatibility commit, or
mixed-source mode. `RUN_AF4C5ABD_ONLY.sh` checks out this commit in the main
repository. `runner/run_skill_assisted_campaign.sh` independently rejects any
mismatch before creating evidence. `final_status.json` repeats both identities.
