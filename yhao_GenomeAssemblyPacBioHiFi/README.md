## A suite of tests for genome assembly with PacBio HiFi data

To run all on dback:

```
sbatch tests.sh
```

To test each assemblers separately:

#### hifiasm

```
sbatch run_hifiasm.sh
```

#### flye

```
sbatch run_flye.sh
```

#### canu

```
sbatch run_canu.sh
```

#### ipa
```
sbatch run_ipa.sh
```