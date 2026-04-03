<?php

use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\File;

Artisan::command(
    'sigep:export-pigia {--path=storage/app/pigia_export.json}',
    function () {
        $outputPath = trim((string) $this->option('path'));
        if ($outputPath === '') {
            $outputPath = 'storage/app/pigia_export.json';
        }

        $pigs = DB::table('pigs')
            ->select([
                'id',
                'name',
                'type',
                'birth_date',
                'weight',
                'created_at',
                'updated_at',
            ])
            ->orderBy('id')
            ->get()
            ->map(fn ($row) => (array) $row)
            ->all();

        $reproductionCycles = DB::table('reproduction_cycles')
            ->select([
                'id',
                'pig_id',
                'boar_id',
                'breeding_date',
                'pregnancy_check_date',
                'is_pregnant',
                'farrowing_date',
                'expecting_farrowing_date',
                'litter_size',
                'post_mating_observation',
                'cycle_stage',
                'weaning_date',
                'end_cycle_date',
                'status_pregnant',
                'expecting_weaning_date',
                'death_litter_size',
                'status_weaning',
                'expecting_slaughter_date',
                'status_pig_end_cycle',
                'expecting_breeding_date',
                'created_at',
                'updated_at',
            ])
            ->orderBy('id')
            ->get()
            ->map(fn ($row) => (array) $row)
            ->all();

        $expenseCategories = DB::table('expense_categories')
            ->select(['id', 'name', 'created_at', 'updated_at'])
            ->orderBy('id')
            ->get()
            ->map(fn ($row) => (array) $row)
            ->all();

        $expenses = DB::table('expenses')
            ->select([
                'id',
                'expense_category_id',
                'amount',
                'description',
                'date',
                'created_at',
                'updated_at',
            ])
            ->orderBy('id')
            ->get()
            ->map(fn ($row) => (array) $row)
            ->all();

        $payload = [
            'meta' => [
                'source' => 'SIGEP',
                'schemaVersion' => 1,
                'exportedAt' => now()->toIso8601String(),
            ],
            'pigs' => $pigs,
            'reproduction_cycles' => $reproductionCycles,
            'expense_categories' => $expenseCategories,
            'expenses' => $expenses,
        ];

        $absolutePath = str_starts_with($outputPath, '/')
            ? $outputPath
            : base_path($outputPath);

        File::ensureDirectoryExists(dirname($absolutePath));
        File::put(
            $absolutePath,
            json_encode(
                $payload,
                JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES,
            ),
        );

        $this->info('Export SIGEP -> PigIA généré: ' . $absolutePath);
        $this->line(
            'Tu peux maintenant importer ce JSON depuis l\'écran Admin de PigIA.',
        );
    },
)->purpose('Exporte pigs/cycles/expenses SIGEP en JSON compatible PigIA');
