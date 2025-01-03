import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:friend_private/backend/mixpanel.dart';
import 'package:friend_private/backend/storage/memories.dart';
import 'package:friend_private/pages/memory_detail/page.dart';
import 'package:friend_private/utils/temp.dart';

class MemoryListItem extends StatefulWidget {
  final int memoryIdx;
  final MemoryRecord memory;
  final Function loadMemories;

  const MemoryListItem({super.key, required this.memory, required this.loadMemories, required this.memoryIdx});

  @override
  State<MemoryListItem> createState() => _MemoryListItemState();
}

class _MemoryListItemState extends State<MemoryListItem> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        MixpanelManager().memoryListItemClicked(widget.memory, widget.memoryIdx);
        await Navigator.of(context).push(MaterialPageRoute(
            builder: (c) => MemoryDetailPage(
                  memory: widget.memory,
                )));
        widget.loadMemories();
      },
      child: Container(
        margin: const EdgeInsets.only(top: 12),
        width: double.maxFinite,
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _getMemoryHeader(),
              const SizedBox(height: 16),
              widget.memory.discarded
                  ? const SizedBox.shrink()
                  : Text(
                      widget.memory.structured.title,
                      style: Theme.of(context).textTheme.titleLarge,
                      maxLines: 1,
                    ),
              widget.memory.discarded ? const SizedBox.shrink() : const SizedBox(height: 8),
              widget.memory.discarded
                  ? const SizedBox.shrink()
                  : Text(
                      widget.memory.structured.overview,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.grey.shade300, height: 1.3),
                      maxLines: 2,
                    ),
              widget.memory.discarded
                  ? Text(
                      widget.memory.transcript.length > 100
                          ? '${utf8.decode(widget.memory.transcript.substring(0, 100).toString().codeUnits)}...'
                          : utf8.decode(widget.memory.transcript.toString().codeUnits) ,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.grey.shade300, height: 1.3),
                    )
                  : const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  _getMemoryHeader() {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, right: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
              child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              widget.memory.discarded
                  ? const SizedBox.shrink()
                  : Text(widget.memory.structured.getEmoji(),
                      style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600)),
              widget.memory.structured.category.isNotEmpty && !widget.memory.discarded
                  ? const SizedBox(
                      width: 12,
                    )
                  : const SizedBox.shrink(),
              widget.memory.structured.category.isNotEmpty
                  ? Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade800,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: Text(widget.memory.discarded ? 'Discarded' : widget.memory.structured.category,
                          style: Theme.of(context).textTheme.bodyMedium),
                    )
                  : const SizedBox.shrink(),
            ],
          )),
          const SizedBox(
            width: 8,
          ),
          Text(
            ' ~ ${dateTimeFormat('MMM d, h:mm a', widget.memory.createdAt)}',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          )
        ],
      ),
    );
  }
}
