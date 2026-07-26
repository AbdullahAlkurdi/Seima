import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:seima/app/theme/spacing.dart';
import 'package:seima/features/mind/presentation/cubit/search_cubit.dart';
import 'package:seima/features/mind/presentation/cubit/search_state.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late SearchCubit _cubit;
  late TextEditingController _controller;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _cubit = GetIt.instance<SearchCubit>();
    _controller = TextEditingController();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        _cubit.search(_controller.text.trim());
      }
    });
  }

  void _openResult(SearchResult result) {
    context.go('/mind/${result.mind.id}');
  }

  void _dismissKeyboard() {
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: _dismissKeyboard,
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        appBar: AppBar(
          title: TextField(
            controller: _controller,
            autofocus: true,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _dismissKeyboard(),
            decoration: const InputDecoration(
              hintText: 'Search minds and nodes...',
              border: InputBorder.none,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            tooltip: 'Back to Library',
            onPressed: () => context.go('/'),
          ),
          actions: [
            if (_controller.text.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.clear),
                tooltip: 'Clear search',
                onPressed: () {
                  _controller.clear();
                  _cubit.clear();
                },
              ),
          ],
        ),
        body: BlocBuilder<SearchCubit, SearchState>(
          builder: (context, state) {
            if (state.query.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search,
                      size: 48,
                      color: cs.onSurfaceVariant.withValues(alpha: 0.4),
                    ),
                    const SizedBox(height: AppSpacing.m),
                    Text(
                      'Search across all your minds',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              );
            }
            if (state.isSearching) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: cs.error),
                    const SizedBox(height: AppSpacing.m),
                    Text(
                      state.error!.message,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: AppSpacing.l),
                    FilledButton(
                      onPressed: () => _cubit.search(state.query),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            if (state.results.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 48,
                      color: cs.onSurfaceVariant.withValues(alpha: 0.4),
                    ),
                    const SizedBox(height: AppSpacing.m),
                    Text(
                      'No results for "${state.query}"',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.m),
              itemCount: state.results.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.s),
              itemBuilder: (context, index) {
                final result = state.results[index];
                return Card(
                  child: ListTile(
                    leading: Icon(
                      result.nodeId != null
                          ? Icons.circle_outlined
                          : Icons.lightbulb_outline,
                      color: cs.primary,
                    ),
                    title: Text(
                      result.matchingText ?? result.mind.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          result.nodeId != null
                              ? '${result.mind.title} › Node'
                              : result.mind.title,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: cs.onSurfaceVariant),
                        ),
                        if (result.matchingTags.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 4,
                            children: result.matchingTags
                                .map(
                                  (tag) => Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: cs.secondaryContainer,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      tag,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(fontSize: 10),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ],
                    ),
                    onTap: () => _openResult(result),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
