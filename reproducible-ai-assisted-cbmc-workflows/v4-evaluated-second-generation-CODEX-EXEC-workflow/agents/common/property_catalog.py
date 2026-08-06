"""Canonical catalogue for the 26 thesis property families.

The catalogue is deterministic control metadata.  It does not assert that a
property is true or automatically provable.  It tells the workflow which
candidate artefact and tool strategy are scientifically appropriate for each
family and which claim boundaries must be preserved.
"""
from __future__ import annotations

from copy import deepcopy
from typing import Any, Dict, Iterable, List, Mapping

JsonDict = Dict[str, Any]

STANDARD = "standard_cbmc_harness"
FUNCTION_CONTRACT = "native_function_contract"
LOOP_CONTRACT = "native_loop_contract"
RELATIONAL = "relational_cbmc_harness"
ANALYSIS_ONLY = "analysis_only_no_formal_claim"
HYBRID = "hybrid_contract_and_harness"

PROPERTY_FAMILIES: List[JsonDict] = [
    {"id":"P01","slug":"array_bounds","title":"Array bounds property","default_strategy":STANDARD,"allowed_strategies":[STANDARD,FUNCTION_CONTRACT,HYBRID],"targets":["poly_add","poly_sub","poly_tobytes","poly_frombytes","polyvec_tobytes","polyvec_frombytes"],"difficulty":"easy","thesis_value":"good","support_level":"production_supported","claim_boundary":"Local memory-access safety under the exact harness, source and options."},
    {"id":"P02","slug":"barrett_reduction_bounds","title":"Barrett reduction bounds","default_strategy":FUNCTION_CONTRACT,"allowed_strategies":[STANDARD,FUNCTION_CONTRACT,HYBRID],"targets":["barrett_reduce"],"difficulty":"easy_medium","thesis_value":"very_good","support_level":"production_supported","claim_boundary":"Implementation-specific output bounds for stated input bounds; not abstract modular correctness."},
    {"id":"P03","slug":"compression_output_range","title":"Compression output range and write extent","default_strategy":HYBRID,"allowed_strategies":[STANDARD,FUNCTION_CONTRACT,HYBRID],"targets":["poly_compress","polyvec_compress"],"difficulty":"medium","thesis_value":"high","support_level":"production_supported","claim_boundary":"Byte/range/write-footprint properties for configured parameter set only."},
    {"id":"P04","slug":"decompression_coefficient_range","title":"Decompression coefficient range","default_strategy":FUNCTION_CONTRACT,"allowed_strategies":[STANDARD,FUNCTION_CONTRACT,HYBRID],"targets":["poly_decompress","polyvec_decompress"],"difficulty":"medium","thesis_value":"high","support_level":"production_supported","claim_boundary":"Implementation-representation bounds, not perfect inverse or cryptographic correctness."},
    {"id":"P05","slug":"encoding_length","title":"Encoding length and frame property","default_strategy":HYBRID,"allowed_strategies":[STANDARD,FUNCTION_CONTRACT,HYBRID],"targets":["poly_tobytes","polyvec_tobytes","pack_pk","pack_sk","pack_ciphertext"],"difficulty":"easy","thesis_value":"good","support_level":"production_supported","claim_boundary":"Writes remain inside the configured official-length buffer; exact-write claims require frame evidence."},
    {"id":"P06","slug":"serialization_round_trip","title":"FromBytes/ToBytes round-trip","default_strategy":RELATIONAL,"allowed_strategies":[RELATIONAL,HYBRID],"targets":["poly_tobytes","poly_frombytes"],"difficulty":"medium_hard","thesis_value":"very_high","support_level":"production_supported_scoped","claim_boundary":"Scoped relational equivalence under explicit normalization assumptions."},
    {"id":"P07","slug":"global_api_buffer_safety","title":"Global API buffer safety","default_strategy":FUNCTION_CONTRACT,"allowed_strategies":[STANDARD,FUNCTION_CONTRACT,HYBRID],"targets":["crypto_kem_keypair","crypto_kem_enc","crypto_kem_dec"],"difficulty":"hard","thesis_value":"high","support_level":"stretch_supported","claim_boundary":"Memory safety for selected API path and configured stubs; not whole implementation correctness."},
    {"id":"P08","slug":"hash_xof_buffer_safety","title":"Hash/XOF buffer safety","default_strategy":STANDARD,"allowed_strategies":[STANDARD,FUNCTION_CONTRACT,HYBRID],"targets":["shake128","shake256","sha3_256","sha3_512"],"difficulty":"medium","thesis_value":"medium","support_level":"production_supported","claim_boundary":"Memory safety and declared buffer extents only."},
    {"id":"P09","slug":"integer_overflow_absence","title":"Integer overflow absence","default_strategy":STANDARD,"allowed_strategies":[STANDARD,FUNCTION_CONTRACT,HYBRID],"targets":["montgomery_reduce","barrett_reduce","fqmul","poly_add","poly_sub","poly_reduce"],"difficulty":"easy_medium","thesis_value":"very_good","support_level":"production_supported","claim_boundary":"C integer overflow checks under recorded ranges and compiler model."},
    {"id":"P10","slug":"packing_consistency","title":"Join/split packing consistency","default_strategy":RELATIONAL,"allowed_strategies":[RELATIONAL,HYBRID],"targets":["pack_pk","unpack_pk","pack_sk","unpack_sk","pack_ciphertext","unpack_ciphertext"],"difficulty":"hard","thesis_value":"very_high","support_level":"production_supported_scoped","claim_boundary":"One selected pack/unpack relation under stated canonicality assumptions."},
    {"id":"P11","slug":"keypair_output_size","title":"Keypair output size/frame","default_strategy":FUNCTION_CONTRACT,"allowed_strategies":[STANDARD,FUNCTION_CONTRACT,HYBRID],"targets":["crypto_kem_keypair"],"difficulty":"medium_hard","thesis_value":"good","support_level":"stretch_supported","claim_boundary":"Write-footprint and buffer safety, not key-generation security or distribution."},
    {"id":"P12","slug":"loop_invariant_generation","title":"Loop invariant generation","default_strategy":LOOP_CONTRACT,"allowed_strategies":[LOOP_CONTRACT,HYBRID,STANDARD],"targets":["poly_add","poly_sub","poly_reduce","poly_tobytes"],"difficulty":"medium","thesis_value":"excellent","support_level":"production_supported","claim_boundary":"Candidate invariant initiation/preservation/use under exact transformed program; no guarantee of automatic discovery success."},
    {"id":"P13","slug":"montgomery_reduction_bounds","title":"Montgomery reduction bounds","default_strategy":FUNCTION_CONTRACT,"allowed_strategies":[STANDARD,FUNCTION_CONTRACT,HYBRID],"targets":["montgomery_reduce"],"difficulty":"medium","thesis_value":"very_high","support_level":"production_supported","claim_boundary":"Implementation-specific Montgomery-domain bounds and overflow conditions."},
    {"id":"P14","slug":"ntt_bounds","title":"NTT input/output bounds","default_strategy":FUNCTION_CONTRACT,"allowed_strategies":[STANDARD,FUNCTION_CONTRACT,HYBRID],"targets":["poly_ntt","poly_invntt_tomont","ntt","invntt"],"difficulty":"hard","thesis_value":"very_high","support_level":"stretch_supported","claim_boundary":"C-level coefficient bounds only; not full NTT mathematical correctness or assembly proof."},
    {"id":"P15","slug":"non_aliasing","title":"Output-buffer separation/non-aliasing","default_strategy":FUNCTION_CONTRACT,"allowed_strategies":[STANDARD,FUNCTION_CONTRACT,HYBRID],"targets":["poly_tobytes","poly_frombytes","pack_pk","unpack_pk","crypto_kem_enc","crypto_kem_dec"],"difficulty":"medium","thesis_value":"high","support_level":"production_supported","claim_boundary":"Explicit aliasing preconditions and their effect; over-constraint must be reviewed."},
    {"id":"P16","slug":"polynomial_add_sub_bounds","title":"Polynomial addition/subtraction bounds","default_strategy":HYBRID,"allowed_strategies":[STANDARD,FUNCTION_CONTRACT,LOOP_CONTRACT,HYBRID],"targets":["poly_add","poly_sub","poly_reduce"],"difficulty":"easy_medium","thesis_value":"high","support_level":"production_supported","claim_boundary":"Local coefficient bounds for the exact representation and input assumptions."},
    {"id":"P17","slug":"q_modulus_range","title":"q-modulus-related range","default_strategy":FUNCTION_CONTRACT,"allowed_strategies":[STANDARD,FUNCTION_CONTRACT,HYBRID],"targets":["barrett_reduce","poly_reduce","poly_decompress","poly_frommsg","poly_tomsg"],"difficulty":"medium","thesis_value":"high","support_level":"production_supported","claim_boundary":"Code-derived q-related representation range; exact interval must not be guessed."},
    {"id":"P18","slug":"rejection_sampling_safety","title":"Rejection sampling safety","default_strategy":LOOP_CONTRACT,"allowed_strategies":[STANDARD,LOOP_CONTRACT,HYBRID],"targets":["rej_uniform","poly_uniform","poly_getnoise_eta1","poly_getnoise_eta2"],"difficulty":"hard","thesis_value":"high","support_level":"stretch_supported","claim_boundary":"Buffer/termination obligations under bounded input/model assumptions; not probabilistic distribution correctness."},
    {"id":"P19","slug":"secret_independent_control_access","title":"Secret-independent branch/access analysis support","default_strategy":ANALYSIS_ONLY,"allowed_strategies":[ANALYSIS_ONLY],"targets":["selected_C_functions"],"difficulty":"hard","thesis_value":"high","support_level":"analysis_only","claim_boundary":"AI-assisted classification and external-test support only; no CBMC constant-time proof claim."},
    {"id":"P20","slug":"decapsulation_memory_safety","title":"Top-level decapsulation memory safety","default_strategy":FUNCTION_CONTRACT,"allowed_strategies":[STANDARD,FUNCTION_CONTRACT,HYBRID],"targets":["crypto_kem_dec"],"difficulty":"hard","thesis_value":"high","support_level":"stretch_supported","claim_boundary":"Selected-path memory safety under official sizes and configured environment."},
    {"id":"P21","slug":"unpack_validation","title":"Unpack validation","default_strategy":HYBRID,"allowed_strategies":[STANDARD,FUNCTION_CONTRACT,HYBRID],"targets":["unpack_pk","unpack_sk","unpack_ciphertext"],"difficulty":"medium","thesis_value":"high","support_level":"production_supported","claim_boundary":"Input-read bounds and output-field ranges for selected format."},
    {"id":"P22","slug":"vector_operation_bounds","title":"Vector operation bounds","default_strategy":HYBRID,"allowed_strategies":[STANDARD,FUNCTION_CONTRACT,LOOP_CONTRACT,HYBRID],"targets":["polyvec_add","polyvec_reduce","polyvec_ntt","polyvec_invntt_tomont"],"difficulty":"medium_hard","thesis_value":"high","support_level":"production_supported_scoped","claim_boundary":"Selected vector operation bounds; NTT variants remain stretch scope."},
    {"id":"P23","slug":"zeroization","title":"Wipe/zeroization","default_strategy":FUNCTION_CONTRACT,"allowed_strategies":[STANDARD,FUNCTION_CONTRACT,HYBRID],"targets":["selected_cleanup_or_wipe"],"difficulty":"medium_hard","thesis_value":"very_high","support_level":"production_supported_scoped","claim_boundary":"Post-call memory bytes in the model; compiler-elimination and physical erasure require separate evidence."},
    {"id":"P24","slug":"xof_deterministic_expansion","title":"XOF deterministic expansion","default_strategy":RELATIONAL,"allowed_strategies":[RELATIONAL,ANALYSIS_ONLY],"targets":["shake128_absorb","shake128_squeezeblocks","shake256"],"difficulty":"hard","thesis_value":"medium","support_level":"test_or_relational_supported","claim_boundary":"Same modeled input/state yields same modeled output; not cryptographic security or deep Keccak correctness."},
    {"id":"P25","slug":"api_return_code","title":"Expected API return-code range","default_strategy":FUNCTION_CONTRACT,"allowed_strategies":[STANDARD,FUNCTION_CONTRACT,HYBRID],"targets":["crypto_kem_keypair","crypto_kem_enc","crypto_kem_dec"],"difficulty":"easy_medium","thesis_value":"medium","support_level":"production_supported","claim_boundary":"Return-value set on modeled paths only."},
    {"id":"P26","slug":"valid_pointer_size_preconditions","title":"Zero-length/invalid-size exclusion and pointer preconditions","default_strategy":FUNCTION_CONTRACT,"allowed_strategies":[FUNCTION_CONTRACT,HYBRID,STANDARD],"targets":["selected_function"],"difficulty":"easy","thesis_value":"excellent","support_level":"production_supported","claim_boundary":"Inferred candidate preconditions must be justified; assumptions are not proved by assuming them."},
]

_BY_ID = {row["id"]: row for row in PROPERTY_FAMILIES}
_BY_SLUG = {row["slug"]: row for row in PROPERTY_FAMILIES}


def property_family_ids() -> List[str]:
    return [row["id"] for row in PROPERTY_FAMILIES]


def strategy_ids() -> List[str]:
    return [STANDARD, FUNCTION_CONTRACT, LOOP_CONTRACT, RELATIONAL, ANALYSIS_ONLY, HYBRID]


def get_property_family(value: str) -> JsonDict:
    key = str(value or "").strip()
    if key in _BY_ID:
        return deepcopy(_BY_ID[key])
    if key in _BY_SLUG:
        return deepcopy(_BY_SLUG[key])
    upper = key.upper()
    if upper in _BY_ID:
        return deepcopy(_BY_ID[upper])
    raise KeyError(f"Unknown property family: {value!r}. Expected one of {property_family_ids()} or a catalogue slug.")


def resolve_strategy(family: Mapping[str, Any], requested: str | None) -> str:
    requested_text = str(requested or "auto").strip()
    strategy = str(family["default_strategy"]) if requested_text in {"", "auto"} else requested_text
    if strategy not in family["allowed_strategies"]:
        raise ValueError(
            f"Strategy {strategy!r} is not allowed for {family['id']} {family['title']!r}; "
            f"allowed: {family['allowed_strategies']}"
        )
    return strategy


def catalogue_summary() -> JsonDict:
    return {
        "schema_version": "property_family_catalogue.v1",
        "property_family_count": len(PROPERTY_FAMILIES),
        "strategy_count": len(strategy_ids()),
        "strategies": strategy_ids(),
        "families": deepcopy(PROPERTY_FAMILIES),
        "claim_boundary": (
            "Catalogue support means the workflow can prepare, review, execute or explicitly classify an experiment. "
            "It never guarantees that an LLM candidate will compile or that CBMC will prove the selected property."
        ),
    }


def validate_catalogue() -> List[str]:
    errors: List[str] = []
    if len(PROPERTY_FAMILIES) != 26:
        errors.append(f"Expected 26 property families, found {len(PROPERTY_FAMILIES)}")
    seen: set[str] = set()
    for row in PROPERTY_FAMILIES:
        pid = str(row.get("id"))
        if pid in seen:
            errors.append(f"Duplicate property id: {pid}")
        seen.add(pid)
        if row.get("default_strategy") not in row.get("allowed_strategies", []):
            errors.append(f"Default strategy not allowed for {pid}")
        for strategy in row.get("allowed_strategies", []):
            if strategy not in strategy_ids():
                errors.append(f"Unknown strategy {strategy} for {pid}")
    return errors
