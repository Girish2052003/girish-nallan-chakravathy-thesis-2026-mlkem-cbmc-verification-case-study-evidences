# References

## Scope

This root reference register identifies the external sources directly relied upon by this research repository for normative grounding, implementation and source identity, formal-verification tooling, prior-assurance comparison, AI/model/API identity, and reproducibility context.

The register contains **19 references**. It is deliberately scoped to sources directly used by this repository's scientific and reproducibility narrative. It does **not** recursively import every dependency, citation, test framework, standard, or third-party source appearing inside the vendored `upstream/mlkem-native` source tree.

The existing evidence spine remains authoritative for claim-to-evidence mapping. This reference register does not rewrite the evidence spine, historical release artefacts, or frozen evidence records.

`CITATION.cff` remains the authoritative machine-readable instruction for citing **this repository itself**. The present file instead records the external literature, standards, software, repositories, and documentation upon which the repository directly relies.

The accompanying [`references.bib`](references.bib) contains the same 19-source bibliography in machine-readable BibTeX-compatible form.

Access dates for living web resources are **25 August 2026**.

## Reference relationship map

| Reference ID | BibTeX key | Repository role | Persistent or canonical source |
| --- | --- | --- | --- |
| `NIST-FIPS203` | `nist2024fips203` | Normative ML-KEM / FIPS 203 grounding | https://doi.org/10.6028/NIST.FIPS.203 |
| `MLKEM-NATIVE` | `pqCodePackageMlkemNative` | Production implementation investigated and exact upstream source identity | https://github.com/pq-code-package/mlkem-native/tree/af4c5abdd5958bdc65a03cd5ee86708264f93304 |
| `MLKEM-SOUNDNESS` | `pqCodePackageMlkemNativeSoundness` | Native formal-assurance scope, assumptions, and risks | https://github.com/pq-code-package/mlkem-native/blob/main/SOUNDNESS.md |
| `FORMOSA-MLKEM` | `formosaCryptoMlkem` | Related proof-oriented ML-KEM implementation and assurance context | https://github.com/formosa-crypto/formosa-mlkem |
| `ALMEIDA-2023` | `almeida2023kyberEpisodeIV` | Formally verified Kyber implementation correctness | https://doi.org/10.46586/tches.v2023.i3.164-193 |
| `ALMEIDA-2024` | `almeida2024kyberEpisodeV` | Machine-checked ML-KEM correctness and IND-CCA assurance | https://doi.org/10.1007/978-3-031-68379-4_12 |
| `ALMEIDA-2025` | `almeida2025fasterVerification` | Verification of optimized ML-KEM implementations | https://doi.org/10.1109/SP61157.2025.00214 |
| `HOL-LIGHT` | `harrison2009holLight` | Interactive theorem-proving and low-level assurance context | https://doi.org/10.1007/978-3-642-03359-9_4 |
| `S2N-BIGNUM` | `amazonS2nBignum` | Low-level cryptographic machine-code proof infrastructure | https://github.com/awslabs/s2n-bignum |
| `S2N-SOUNDNESS` | `amazonS2nBignumSoundness` | Soundness and trusted-boundary documentation for s2n-bignum | https://github.com/awslabs/s2n-bignum/blob/main/SOUNDNESS.md |
| `HACLSTAR` | `zinzindohoue2017haclstar` | Broader verified cryptographic implementation context | https://doi.org/10.1145/3133956.3134043 |
| `EVERCRYPT` | `protzenko2020evercrypt` | Broader verified cross-platform cryptographic implementation context | https://doi.org/10.1109/SP40000.2020.00114 |
| `CBMC-PAPER` | `kroeningTautschnig2014cbmc` | Peer-reviewed scientific reference for CBMC | https://doi.org/10.1007/978-3-642-54862-8_26 |
| `CBMC-SOFTWARE` | `diffblueCbmc` | Formal-verification software used in the experiments; experimental version 6.9.0 | https://github.com/diffblue/cbmc/releases/tag/cbmc-6.9.0 |
| `OPENAI-CODEX` | `openaiCodex` | Repository-aware software agent used in the later workflow | https://github.com/openai/codex |
| `BOLIN-2026-CODEX` | `bolin2026codexAgentLoop` | Primary-source description of the Codex agent loop | https://openai.com/index/unrolling-the-codex-agent-loop/ |
| `ARRANZ-OLMOS-2024-ZEROIZATION` | `arranzOlmos2024zeroization` | Formal-verification literature directly relevant to zeroisation | https://doi.org/10.46586/tches.v2024.i1.375-397 |
| `OPENAI-GPT54` | `openaiGpt54` | V3 GPT-5.4 model identity and reasoning configuration context | https://developers.openai.com/api/docs/models/gpt-5.4 |
| `OPENAI-API` | `openaiApiReference` | V3 API-backed LLM workflow interface | https://developers.openai.com/api/reference/overview |

## Harvard reference list

Almeida, J.B., Barbosa, M., Barthe, G., Grégoire, B., Laporte, V., Léchenet, J.-C., Oliveira, T., Pacheco, H., Quaresma, M., Schwabe, P., Séré, A. and Strub, P.-Y. (2023) ‘Formally verifying Kyber Episode IV: Implementation correctness’, *IACR Transactions on Cryptographic Hardware and Embedded Systems*, 2023(3), pp. 164–193. doi: [10.46586/tches.v2023.i3.164-193](https://doi.org/10.46586/tches.v2023.i3.164-193).

Almeida, J.B., Arranz-Olmos, S., Barbosa, M., Barthe, G., Dupressoir, F., Grégoire, B., Laporte, V., Léchenet, J.-C., Low, C., Oliveira, T., Pacheco, H., Quaresma, M., Schwabe, P. and Strub, P.-Y. (2024) ‘Formally Verifying Kyber – Episode V: Machine-Checked IND-CCA Security and Correctness of ML-KEM in EasyCrypt’, in Reyzin, L. and Stebila, D. (eds.) *Advances in Cryptology – CRYPTO 2024, Part II*. Lecture Notes in Computer Science, 14921. Cham: Springer, pp. 384–421. doi: [10.1007/978-3-031-68379-4_12](https://doi.org/10.1007/978-3-031-68379-4_12).

Almeida, J.B., Delerue Marinho Alves, G.X., Barbosa, M., Barthe, G., Esquível, L., Hwang, V., Oliveira, T., Pacheco, H., Schwabe, P. and Strub, P.-Y. (2025) ‘Faster Verification of Faster Implementations: Combining Deductive and Circuit-Based Reasoning in EasyCrypt’, in Blanton, M., Enck, W. and Nita-Rotaru, C. (eds.) *Proceedings – 46th IEEE Symposium on Security and Privacy, SP 2025*. IEEE, pp. 3820–3838. doi: [10.1109/SP61157.2025.00214](https://doi.org/10.1109/SP61157.2025.00214).

Amazon Web Services (n.d.-a) *s2n-bignum* [Computer software and formal proof artefacts]. GitHub. Available at: https://github.com/awslabs/s2n-bignum (Accessed: 25 August 2026).

Amazon Web Services (n.d.-b) *Soundness of s2n-bignum Formal Verification* [Software assurance documentation]. GitHub. Available at: https://github.com/awslabs/s2n-bignum/blob/main/SOUNDNESS.md (Accessed: 25 August 2026).

Arranz-Olmos, S., Barthe, G., Gonzalez, R., Grégoire, B., Laporte, V., Léchenet, J.-C., Oliveira, T. and Schwabe, P. (2024) ‘High-assurance zeroization’, *IACR Transactions on Cryptographic Hardware and Embedded Systems*, 2024(1), pp. 375–397. doi: [10.46586/tches.v2024.i1.375-397](https://doi.org/10.46586/tches.v2024.i1.375-397).

Bolin, M. (2026) ‘Unrolling the Codex agent loop’, *OpenAI*, 23 January. Available at: https://openai.com/index/unrolling-the-codex-agent-loop/ (Accessed: 25 August 2026).

Diffblue (n.d.) *CBMC: C Bounded Model Checker* [Computer software]. GitHub. Version used in this research: 6.9.0. Available at: https://github.com/diffblue/cbmc (Accessed: 25 August 2026). Version 6.9.0 release: https://github.com/diffblue/cbmc/releases/tag/cbmc-6.9.0.

Formosa Crypto (n.d.) *formosa-mlkem* [Computer software and formal proof artefacts]. GitHub. Available at: https://github.com/formosa-crypto/formosa-mlkem (Accessed: 25 August 2026).

Harrison, J. (2009) ‘HOL Light: An Overview’, in Berghofer, S., Nipkow, T., Urban, C. and Wenzel, M. (eds.) *Theorem Proving in Higher Order Logics*. Lecture Notes in Computer Science, 5674. Berlin, Heidelberg: Springer, pp. 60–66. doi: [10.1007/978-3-642-03359-9_4](https://doi.org/10.1007/978-3-642-03359-9_4).

Kroening, D. and Tautschnig, M. (2014) ‘CBMC – C Bounded Model Checker’, in Ábrahám, E. and Havelund, K. (eds.) *Tools and Algorithms for the Construction and Analysis of Systems*. Lecture Notes in Computer Science, 8413. Berlin, Heidelberg: Springer, pp. 389–391. doi: [10.1007/978-3-642-54862-8_26](https://doi.org/10.1007/978-3-642-54862-8_26).

National Institute of Standards and Technology (2024) *Module-Lattice-Based Key-Encapsulation Mechanism Standard*. Federal Information Processing Standards Publication 203. Gaithersburg, MD: National Institute of Standards and Technology. doi: [10.6028/NIST.FIPS.203](https://doi.org/10.6028/NIST.FIPS.203).

OpenAI (n.d.-a) *Codex* [Computer software]. GitHub. Available at: https://github.com/openai/codex (Accessed: 25 August 2026).

OpenAI (n.d.-b) *GPT-5.4 model* [Model documentation]. OpenAI API documentation. Available at: https://developers.openai.com/api/docs/models/gpt-5.4 (Accessed: 25 August 2026).

OpenAI (n.d.-c) *OpenAI API reference* [Technical documentation]. Available at: https://developers.openai.com/api/reference/overview (Accessed: 25 August 2026).

Post-Quantum Code Package (n.d.-a) *Formal Verification in mlkem-native: Scope, Assumptions, Risks* [Software assurance documentation]. GitHub. Available at: https://github.com/pq-code-package/mlkem-native/blob/main/SOUNDNESS.md (Accessed: 25 August 2026).

Post-Quantum Code Package (n.d.-b) *mlkem-native: Secure, fast, and portable C90 implementation of ML-KEM / FIPS 203* [Computer software]. GitHub. Available at: https://github.com/pq-code-package/mlkem-native (Accessed: 25 August 2026). Research source snapshot: commit `af4c5abdd5958bdc65a03cd5ee86708264f93304`, available at: https://github.com/pq-code-package/mlkem-native/tree/af4c5abdd5958bdc65a03cd5ee86708264f93304.

Protzenko, J., Parno, B., Fromherz, A., Hawblitzel, C., Polubelova, M., Bhargavan, K., Beurdouche, B., Choi, J., Delignat-Lavaud, A., Fournet, C., Kulatova, N., Ramananandro, T., Rastogi, A., Swamy, N., Wintersteiger, C.M. and Zanella-Béguelin, S. (2020) ‘EverCrypt: A Fast, Verified, Cross-Platform Cryptographic Provider’, in *2020 IEEE Symposium on Security and Privacy (SP)*. IEEE, pp. 983–1002. doi: [10.1109/SP40000.2020.00114](https://doi.org/10.1109/SP40000.2020.00114).

Zinzindohoué, J.-K., Bhargavan, K., Protzenko, J. and Beurdouche, B. (2017) ‘HACL*: A Verified Modern Cryptographic Library’, in *Proceedings of the 2017 ACM SIGSAC Conference on Computer and Communications Security*. New York: ACM, pp. 1789–1806. doi: [10.1145/3133956.3134043](https://doi.org/10.1145/3133956.3134043).

## Reproducibility notes

### mlkem-native source identity

The production source snapshot investigated by this repository is bound to upstream `mlkem-native` commit:

`af4c5abdd5958bdc65a03cd5ee86708264f93304`

Persistent source view:

https://github.com/pq-code-package/mlkem-native/tree/af4c5abdd5958bdc65a03cd5ee86708264f93304

The moving upstream `main` branch is cited for project identity and living documentation. It does not replace the frozen source identity preserved by the research evidence.

### CBMC identity

The formal-verification engine used by the case study is **CBMC 6.9.0**.

Official release:

https://github.com/diffblue/cbmc/releases/tag/cbmc-6.9.0

The Kroening and Tautschnig (2014) paper provides the scholarly CBMC reference. The software record and release URL separately establish tool identity and reproducibility.

### GPT-5.4 and API identity

The V3 repository evidence identifies an API-backed GPT-5.4 workflow and its recorded reasoning configurations. The official GPT-5.4 documentation and OpenAI API reference resolve the model family and API interface.

No versioned GPT-5.4 snapshot is inferred here unless it is explicitly established by the preserved experiment evidence.

### Codex identity

The Codex software repository and Bolin (2026) provide external platform and agent-loop context. Exact experiment-specific model, invocation, and run identities remain governed by the retained repository evidence rather than by the moving state of current product documentation.

## Relationship to the frozen evidence spine

The evidence spine already contains shorthand labels such as FIPS 203, mlkem-native assurance documentation, Formosa/Almeida work, HOL Light/s2n-bignum, HACL*, and EverCrypt. This root register resolves those external source families without altering any frozen evidence-spine file.

Year-letter or `n.d.` suffixes appearing in previously frozen evidence-spine shorthand are historical labels within those records. This standalone bibliography uses its own internally consistent Harvard author-date ordering and does not retroactively rewrite frozen evidence.

## Completeness boundary

For this repository, reference completeness means coverage of external sources directly required for:

1. normative ML-KEM grounding;
2. production implementation and source identity;
3. formal-verification method and software identity;
4. native and comparative assurance context;
5. AI model, API, and agent-platform identity; and
6. reproducibility of the investigated source/tool configuration.

It does not mean recursively reproducing the bibliography of vendored upstream source code or citing every ordinary infrastructure dependency merely because that dependency appears somewhere inside the repository.

## Machine-readable bibliography

The same 19-source set is provided in [`references.bib`](references.bib).
