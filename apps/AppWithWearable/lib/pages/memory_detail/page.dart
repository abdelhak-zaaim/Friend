import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:friend_private/backend/mixpanel.dart';
import 'package:friend_private/backend/storage/memories.dart';
import 'package:friend_private/pages/memories/widgets/confirm_deletion_widget.dart';
import 'package:friend_private/utils/temp.dart';
import 'package:share_plus/share_plus.dart';

class MemoryDetailPage extends StatefulWidget {
  final MemoryRecord memory;

  const MemoryDetailPage({super.key, required this.memory});

  @override
  State<MemoryDetailPage> createState() => _MemoryDetailPageState();
}

class _MemoryDetailPageState extends State<MemoryDetailPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final focusTitleField = FocusNode();
  final focusOverviewField = FocusNode();

  TextEditingController titleController = TextEditingController();
  TextEditingController overviewController = TextEditingController();
  TextEditingController actionItemsController = TextEditingController();
  bool editingTitle = false;
  bool editingOverview = false;

  @override
  void initState() {
    titleController.text = widget.memory.structured.title;
    overviewController.text = widget.memory.structured.overview;
    actionItemsController.text = widget.memory.structured.actionItems.join('\n');
    super.initState();
  }

  @override
  void dispose() {
    titleController.dispose();
    overviewController.dispose();
    actionItemsController.dispose();
    focusTitleField.dispose();
    focusOverviewField.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Theme.of(context).colorScheme.primary,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () async {
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  size: 24.0,
                ),
              ),
              Expanded(
                child: Text(
                    " ${widget.memory.structured.getEmoji()} ${widget.memory.discarded ? 'Discarded Memory' : widget.memory.structured.title}"),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {
                  showModalBottomSheet(
                      context: context,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      builder: (context) => Container(
                            height: 216,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            child: Column(
                              children: [
                                ListTile(
                                  title: const Text('Share memory'),
                                  leading: const Icon(Icons.send),
                                  onTap: () {
                                    // share loading
                                    MixpanelManager().memoryShareButtonClick(widget.memory);
                                    Share.share(widget.memory.getStructuredString());
                                    HapticFeedback.lightImpact();
                                  },
                                ),
                                // ListTile(
                                //   title: const Text('Edit'),
                                //   leading: const Icon(Icons.edit),
                                //   onTap: () {},
                                // ),
                                ListTile(
                                  title: const Text('Delete'),
                                  leading: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (dialogContext) {
                                        return Dialog(
                                          elevation: 0,
                                          insetPadding: EdgeInsets.zero,
                                          backgroundColor: Colors.transparent,
                                          alignment:
                                              const AlignmentDirectional(0.0, 0.0).resolve(Directionality.of(context)),
                                          child: ConfirmDeletionWidget(
                                              memory: widget.memory, onDelete: (){
                                            Navigator.pop(context, true);
                                            Navigator.pop(context, true);
                                          }),
                                        );
                                      },
                                    ).then((value) => setState(() {}));
                                  },
                                )
                              ],
                            ),
                          ));
                },
                icon: const Icon(Icons.more_horiz),
              ),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ListView(
            children: [
              const SizedBox(height: 24),
              Text(widget.memory.structured.getEmoji(),
                  style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              Text(
                widget.memory.discarded ? 'Discarded Memory' : widget.memory.structured.title,
                style: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 32),
              ),
              const SizedBox(height: 16),
              Table(
                border: TableBorder.all(color: Colors.black),
                columnWidths: const {
                  0: FlexColumnWidth(1),
                  1: FlexColumnWidth(2),
                },
                children: [
                  TableRow(
                    children: [
                      Text(
                        'Date Created',
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Colors.grey.shade400),
                      ),
                      Text(
                        dateTimeFormat('MMM d,  yyyy', widget.memory.createdAt),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const TableRow(children: [SizedBox(height: 12), SizedBox(height: 12)]),
                  TableRow(children: [
                    Text(
                      'Time Created',
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Colors.grey.shade400),
                    ),
                    Text(
                      dateTimeFormat('h:mm a', widget.memory.createdAt),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ]),
                  TableRow(children: [
                    SizedBox(height: widget.memory.structured.category.isNotEmpty ? 12 : 0),
                    SizedBox(height: widget.memory.structured.category.isNotEmpty ? 12 : 0),
                  ]),
                  widget.memory.structured.category.isNotEmpty
                      ? TableRow(children: [
                          Text(
                            'Category',
                            style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Colors.grey.shade400),
                          ),
                          Text(
                            widget.memory.structured.category,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ])
                      : const TableRow(children: [SizedBox(height: 0), SizedBox(height: 0)]),
                ],
              ),
              const SizedBox(height: 40),
              widget.memory.discarded
                  ? const SizedBox.shrink()
                  : Text(
                      'Overview',
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 26),
                    ),
              widget.memory.discarded ? const SizedBox.shrink() : const SizedBox(height: 8),
              widget.memory.discarded
                  ? const SizedBox.shrink()
                  : _getEditTextField(overviewController, editingOverview, focusOverviewField),
              widget.memory.discarded ? const SizedBox.shrink() : const SizedBox(height: 40),
              widget.memory.structured.actionItems.isNotEmpty
                  ? Text(
                      'Action Items',
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 26),
                    )
                  : const SizedBox.shrink(),
              widget.memory.structured.actionItems.isNotEmpty ? const SizedBox(height: 8) : const SizedBox.shrink(),
              ...widget.memory.structured.actionItems.map<Widget>((item) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Checkbox(
                        value: false,
                        onChanged: (v) {},
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0))),
                    Expanded(
                      child: Text(item, style: TextStyle(color: Colors.grey.shade300, fontSize: 15, height: 1.3)),
                    ),
                  ],
                );
              }),
              if (widget.memory.structured.pluginsResponse.isNotEmpty && !widget.memory.discarded) ...[
                const SizedBox(height: 40),
                Text(
                  'Plugins 🧑‍💻',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 26),
                ),
                const SizedBox(height: 24),
                ...widget.memory.structured.pluginsResponse.map((response) => Container(
                      margin: const EdgeInsets.only(bottom: 32),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade900,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ExpandableTextWidget(
                        text: response.trim(),
                        style: TextStyle(color: Colors.grey.shade300, fontSize: 15, height: 1.3),
                        maxLines: 6,
                        // Change this to 6 if you want the initial max lines to be 6
                        linkColor: Colors.white,
                      ),
                    )),
              ],
              const SizedBox(height: 8),
              Text(
                'Raw Transcript  💬',
                style: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 26),
              ),
              const SizedBox(height: 16),
              ExpandableTextWidget(
                text: utf8.decode(widget.memory.transcript.toString().codeUnits),
                maxLines: 6,
                linkColor: Colors.grey.shade300,
                style: TextStyle(color: Colors.grey.shade300, fontSize: 15, height: 1.3),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  _getEditTextField(TextEditingController controller, bool enabled, FocusNode focusNode) {
    if (widget.memory.discarded) return const SizedBox.shrink();
    return enabled
        ? TextField(
            controller: controller,
            keyboardType: TextInputType.multiline,
            focusNode: focusNode,
            maxLines: null,
            decoration: const InputDecoration(
              border: OutlineInputBorder(borderSide: BorderSide.none),
              contentPadding: EdgeInsets.all(0),
            ),
            enabled: enabled,
            style: TextStyle(color: Colors.grey.shade300, fontSize: 15, height: 1.3),
          )
        : SelectionArea(
            child: Text(
            controller.text,
            style: TextStyle(color: Colors.grey.shade300, fontSize: 15, height: 1.3),
          ));
  }
}

class ExpandableTextWidget extends StatefulWidget {
  final String text;
  final TextStyle style;
  final int maxLines;
  final String expandText;
  final String collapseText;
  final Color linkColor;

  const ExpandableTextWidget({
    super.key,
    required this.text,
    required this.style,
    this.maxLines = 3,
    this.expandText = 'show more ↓',
    this.collapseText = 'show less ↑',
    this.linkColor = Colors.deepPurple,
  });

  @override
  _ExpandableTextWidgetState createState() => _ExpandableTextWidgetState();
}

class _ExpandableTextWidgetState extends State<ExpandableTextWidget> {
  bool _isExpanded = false;

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final span = TextSpan(text: widget.text, style: widget.style);
    final tp = TextPainter(
      text: span,
      maxLines: widget.maxLines,
      textDirection: TextDirection.ltr,
    );
    tp.layout(maxWidth: MediaQuery.of(context).size.width);
    final isOverflowing = tp.didExceedMaxLines;

    return SelectionArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.text,
            style: widget.style,
            maxLines: _isExpanded ? 100 : widget.maxLines,
            overflow: TextOverflow.ellipsis,
          ),
          if (isOverflowing)
            InkWell(
              onTap: _toggleExpand,
              child: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  _isExpanded ? widget.collapseText : widget.expandText,
                  style: TextStyle(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.w500,
                    fontSize: widget.style.fontSize,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
