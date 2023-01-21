import 'package:flutter/material.dart';

class RefreshAppBarIcon extends StatefulWidget {
  final void Function() onRefreshedCallback;

  const RefreshAppBarIcon({
    super.key,
    required this.onRefreshedCallback,
  });

  @override
  State<RefreshAppBarIcon> createState() => _RefreshAppBarIconState();
}

class _RefreshAppBarIconState extends State<RefreshAppBarIcon> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(
        12,
      ),
      child: InkWell(
        onTap: () => widget.onRefreshedCallback(),
        splashColor: Colors.purple,
        child: const Icon(
          Icons.refresh_outlined,
        ),
      ),
    );
  }
}
