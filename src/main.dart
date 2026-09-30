import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'security.dart';

const kBlue = Color(0xFF1257A6);
final themeMode = ValueNotifier<ThemeMode>(ThemeMode.light);

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext c) => ValueListenableBuilder<ThemeMode>(
        valueListenable: themeMode,
        builder: (_, m, __) => MaterialApp(
          title: 'Є-Гідність',
          debugShowCheckedModeBanner: false,
          themeMode: m,
          theme: ThemeData(useMaterial3: true, colorSchemeSeed: kBlue),
          darkTheme: ThemeData(useMaterial3: true, colorSchemeSeed: kBlue, brightness: Brightness.dark),
          builder: (ctx, child) => LockGate(child: child!),
          home: const Login(),
        ),
      );
}

Route fade(Widget w) => PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (_, a, __) => w,
      transitionsBuilder: (_, a, __, child) => FadeTransition(
          opacity: a,
          child: SlideTransition(
              position: Tween(begin: const Offset(0, .04), end: Offset.zero)
                  .animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
              child: child)),
    );

class Login extends StatefulWidget {
  const Login({super.key});
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool busy = false;
  void go() async {
    setState(() => busy = true);
    await Future.delayed(const Duration(milliseconds: 1400));
    if (mounted) Navigator.pushReplacement(context, fade(const Chats()));
  }

  @override
  Widget build(BuildContext c) => Scaffold(
        body: Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
                  colors: [Color(0xFF0C3563), kBlue])),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.elasticOut,
                  builder: (_, v, ch) => Transform.scale(scale: v, child: ch),
                  child: Container(
                    width: 96, height: 96,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28)),
                    child: const Icon(Icons.shield_rounded, size: 54, color: kBlue),
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Є-Гідність', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800)),
                const SizedBox(height: 10),
                const Text('Безпечний український месенджер.\nСкрізне шифрування. Без реклами.',
                    textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 15, height: 1.4)),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity, height: 52,
                  child: FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: kBlue),
                    onPressed: busy ? null : go,
                    child: busy
                        ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5))
                        : const Text('Увійти через Дію', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 14),
                const Text('Демо-версія', style: TextStyle(color: Colors.white54)),
              ]),
            ),
          ),
        ),
      );
}

class Contact {
  final String name, last;
  final Color color;
  final bool secret;
  const Contact(this.name, this.last, this.color, {this.secret = false});
}

const contacts = [
  Contact('Олена Коваленко', 'Слава Україні! 🇺🇦', Color(0xFF2E7FC1)),
  Contact('Андрій Шевченко', 'Документи надіслав', Color(0xFF1E7A46)),
  Contact('Секретний чат', 'Повідомлення зникають', Color(0xFF8A2E27), secret: true),
  Contact('Родина', 'Мама: Коли приїдеш?', Color(0xFFB36B00)),
  Contact('Група «Волонтери»', 'Ігор: Збір у суботу о 10:00', Color(0xFF00897B)),
  Contact('Канал: Новини', 'Головне за добу', Color(0xFF455A64)),
  Contact('Марія Бондар', 'Дякую, до зустрічі!', Color(0xFF6A3FA0)),
];

class Chats extends StatefulWidget {
  const Chats({super.key});
  @override
  State<Chats> createState() => _ChatsState();
}

class _ChatsState extends State<Chats> {
  final items = List<Contact>.of(contacts);
  final pinned = <String>{};
  final unread = {'Олена Коваленко': 2, 'Родина': 5, 'Група «Волонтери»': 12};
  String q = '';
  bool searching = false;

  List<Contact> get shown {
    final l = items.where((k) => k.name.toLowerCase().contains(q.toLowerCase())).toList();
    l.sort((a, b) => (pinned.contains(b.name) ? 1 : 0) - (pinned.contains(a.name) ? 1 : 0));
    return l;
  }

  @override
  Widget build(BuildContext c) {
    final cs = Theme.of(c).colorScheme;
    final list = shown;
    return Scaffold(
      appBar: AppBar(
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: searching
              ? TextField(key: const ValueKey('s'), autofocus: true, onChanged: (v) => setState(() => q = v),
                  decoration: const InputDecoration(hintText: 'Пошук чатів', border: InputBorder.none))
              : const Text('Чати', key: ValueKey('t'), style: TextStyle(fontWeight: FontWeight.w800)),
        ),
        actions: [
          IconButton(icon: Icon(searching ? Icons.close : Icons.search),
              onPressed: () => setState(() { searching = !searching; q = ''; })),
          IconButton(icon: const Icon(Icons.settings_outlined), onPressed: () => Navigator.push(c, fade(const SettingsPage()))),
        ],
      ),
      body: list.isEmpty
          ? const Center(child: Text('Нічого не знайдено'))
          : ListView.builder(
              itemCount: list.length,
              itemBuilder: (_, i) {
                final k = list[i];
                final n = unread[k.name] ?? 0;
                return TweenAnimationBuilder<double>(
                  key: ValueKey(k.name),
                  tween: Tween(begin: 0, end: 1),
                  duration: Duration(milliseconds: 350 + i * 80),
                  curve: Curves.easeOutCubic,
                  builder: (_, v, ch) => Opacity(opacity: v, child: Transform.translate(offset: Offset(30 * (1 - v), 0), child: ch)),
                  child: Dismissible(
                    key: ValueKey('d${k.name}'),
                    background: Container(color: cs.error, alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 24), child: const Icon(Icons.delete, color: Colors.white)),
                    direction: DismissDirection.endToStart,
                    onDismissed: (_) => setState(() => items.remove(k)),
                    child: ListTile(
                      leading: Hero(
                        tag: k.name,
                        child: CircleAvatar(radius: 26, backgroundColor: k.color,
                            child: k.secret ? const Icon(Icons.lock, color: Colors.white)
                                : Text(k.name.replaceAll(RegExp('[^А-Яа-яІіЇїЄєA-Za-z]'), '')[0], style: const TextStyle(color: Colors.white, fontSize: 19))),
                      ),
                      title: Text(k.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Text(k.last, maxLines: 1, overflow: TextOverflow.ellipsis),
                      trailing: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        if (pinned.contains(k.name)) Icon(Icons.push_pin, size: 15, color: cs.onSurfaceVariant),
                        if (n > 0)
                          AnimatedScale(scale: 1, duration: const Duration(milliseconds: 300),
                              child: Container(margin: const EdgeInsets.only(top: 4), padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(color: kBlue, borderRadius: BorderRadius.circular(12)),
                                  child: Text('$n', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)))),
                      ]),
                      onLongPress: () => setState(() => pinned.contains(k.name) ? pinned.remove(k.name) : pinned.add(k.name)),
                      onTap: () async {
                        await Navigator.push(c, fade(ChatPage(k)));
                        setState(() => unread.remove(k.name));
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(onPressed: () {}, child: const Icon(Icons.edit)),
    );
  }
}

class Dots extends StatefulWidget {
  const Dots({super.key});
  @override
  State<Dots> createState() => _DotsState();
}

class _DotsState extends State<Dots> with SingleTickerProviderStateMixin {
  late final a = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat();
  @override
  void dispose() {
    a.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext c) => Container(
        margin: const EdgeInsets.all(6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(color: Theme.of(c).colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(18)),
        child: AnimatedBuilder(
          animation: a,
          builder: (_, __) => Row(mainAxisSize: MainAxisSize.min, children: [
            for (var i = 0; i < 3; i++)
              Transform.translate(
                offset: Offset(0, -5 * math.max(0.0, math.sin(a.value * 2 * math.pi - i * .9))),
                child: Container(margin: const EdgeInsets.symmetric(horizontal: 2), width: 8, height: 8,
                    decoration: BoxDecoration(color: kBlue.withOpacity(.7), shape: BoxShape.circle)),
              ),
          ]),
        ),
      );
}

class Msg {
  final String text;
  final bool mine;
  final DateTime t = DateTime.now();
  String? reaction;
  final Msg? reply;
  Msg(this.text, this.mine, [this.reply]);
}

class ChatPage extends StatefulWidget {
  final Contact k;
  const ChatPage(this.k, {super.key});
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final msgs = <Msg>[];
  final ctl = TextEditingController();
  final scroll = ScrollController();
  late bool timer = widget.k.secret;
  bool typing = false;
  Msg? replyTo;
  static const replies = ['Добре, зрозуміло 👍', 'Дякую!', 'Домовились', 'Слава Україні!', 'Героям слава! 🇺🇦'];
  int ri = 0;

  @override
  void initState() {
    super.initState();
    msgs.add(Msg(widget.k.last, false));
  }

  void toEnd() => WidgetsBinding.instance.addPostFrameCallback((_) {
        if (scroll.hasClients) scroll.animateTo(0, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      });

  void add(Msg m) {
    setState(() => msgs.add(m));
    toEnd();
    if (timer) {
      Timer(const Duration(seconds: 10), () {
        if (mounted) setState(() => msgs.remove(m));
      });
    }
  }

  void send() {
    final t = ctl.text.trim();
    if (t.isEmpty) return;
    ctl.clear();
    add(Msg(t, true, replyTo));
    replyTo = null;
    setState(() => typing = true);
    Timer(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() => typing = false);
      add(Msg(replies[ri++ % replies.length], false));
    });
  }

  void react(Msg m) => showModalBottomSheet(
        context: context,
        builder: (_) => SafeArea(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Wrap(spacing: 14, alignment: WrapAlignment.center, children: [
                for (final e in ['❤️', '👍', '🔥', '😂', '🇺🇦', '🙏'])
                  GestureDetector(
                    onTap: () {
                      setState(() => m.reaction = e);
                      Navigator.pop(context);
                    },
                    child: Text(e, style: const TextStyle(fontSize: 34)),
                  ),
              ]),
            ),
            ListTile(
              leading: const Icon(Icons.reply),
              title: const Text('Відповісти'),
              onTap: () {
                setState(() => replyTo = m);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Копіювати'),
              onTap: () {
                Clipboard.setData(ClipboardData(text: m.text));
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Видалити'),
              onTap: () {
                setState(() => msgs.remove(m));
                Navigator.pop(context);
              },
            ),
          ]),
        ),
      );

  @override
  Widget build(BuildContext c) {
    final cs = Theme.of(c).colorScheme;
    final list = msgs.reversed.toList();
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(children: [
          Hero(tag: widget.k.name, child: CircleAvatar(radius: 18, backgroundColor: widget.k.color,
              child: Text(widget.k.name[0], style: const TextStyle(color: Colors.white)))),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(widget.k.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            Text(typing ? 'друкує…' : 'в мережі', style: TextStyle(fontSize: 12, color: typing ? cs.primary : cs.onSurfaceVariant)),
          ])),
        ]),
        actions: [
          IconButton(
            tooltip: 'Зникаючі повідомлення',
            icon: Icon(timer ? Icons.timer : Icons.timer_outlined, color: timer ? cs.primary : null),
            onPressed: () {
              setState(() => timer = !timer);
              ScaffoldMessenger.of(c).showSnackBar(SnackBar(
                  content: Text(timer ? 'Повідомлення зникатимуть через 10 с' : 'Зникання вимкнено')));
            },
          ),
        ],
      ),
      body: Column(children: [
        Container(
          width: double.infinity,
          color: cs.primaryContainer.withOpacity(.5),
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: const Text('🔒 Скрізне шифрування увімкнено', textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
        ),
        Expanded(
          child: ListView.builder(
            controller: scroll,
            reverse: true,
            padding: const EdgeInsets.all(12),
            itemCount: list.length + (typing ? 1 : 0),
            itemBuilder: (_, i) {
              if (typing && i == 0) return const Align(alignment: Alignment.centerLeft, child: Dots());
              final m = list[typing ? i - 1 : i];
              return TweenAnimationBuilder<double>(
                key: ObjectKey(m),
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutBack,
                builder: (_, v, ch) => Opacity(
                    opacity: v.clamp(0, 1),
                    child: Transform.scale(scale: .85 + .15 * v, alignment: m.mine ? Alignment.bottomRight : Alignment.bottomLeft, child: ch)),
                child: Align(
                  alignment: m.mine ? Alignment.centerRight : Alignment.centerLeft,
                  child: GestureDetector(
                    onLongPress: () => react(m),
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 3),
                      padding: const EdgeInsets.fromLTRB(14, 9, 12, 7),
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(c).size.width * .78),
                      decoration: BoxDecoration(
                        color: m.mine ? kBlue : cs.surfaceContainerHighest,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(18), topRight: const Radius.circular(18),
                          bottomLeft: Radius.circular(m.mine ? 18 : 4), bottomRight: Radius.circular(m.mine ? 4 : 18)),
                      ),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.end, mainAxisSize: MainAxisSize.min, children: [
                        if (m.reply != null)
                          Container(
                            margin: const EdgeInsets.only(bottom: 4),
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(8),
                                border: Border(left: BorderSide(color: m.mine ? Colors.white : kBlue, width: 3))),
                            child: Text(m.reply!.text, maxLines: 1, overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 12.5, color: m.mine ? Colors.white70 : null)),
                          ),
                        Text(m.text, style: TextStyle(fontSize: 15.5, color: m.mine ? Colors.white : cs.onSurface)),
                        const SizedBox(height: 2),
                        Text(
                          '${m.reaction ?? ''} ${m.t.hour.toString().padLeft(2, '0')}:${m.t.minute.toString().padLeft(2, '0')}${m.mine ? ' ✓✓' : ''}',
                          style: TextStyle(fontSize: 11, color: m.mine ? Colors.white70 : cs.onSurfaceVariant),
                        ),
                      ]),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          child: replyTo == null
              ? const SizedBox(width: double.infinity)
              : Container(
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(10, 4, 10, 0),
                  padding: const EdgeInsets.fromLTRB(12, 6, 4, 6),
                  decoration: BoxDecoration(color: cs.primaryContainer.withOpacity(.6), borderRadius: BorderRadius.circular(12)),
                  child: Row(children: [
                    const Icon(Icons.reply, size: 18, color: kBlue),
                    const SizedBox(width: 8),
                    Expanded(child: Text(replyTo!.text, maxLines: 1, overflow: TextOverflow.ellipsis)),
                    IconButton(icon: const Icon(Icons.close, size: 18), onPressed: () => setState(() => replyTo = null)),
                  ]),
                ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 4, 10, 8),
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: ctl,
                  onChanged: (_) => setState(() {}),
                  onSubmitted: (_) => send(),
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: 'Повідомлення',
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(26), borderSide: BorderSide.none),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(radius: 24, backgroundColor: kBlue,
                  child: IconButton(
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder: (w, a) => ScaleTransition(scale: a, child: RotationTransition(turns: Tween(begin: .8, end: 1.0).animate(a), child: w)),
                      child: Icon(ctl.text.trim().isEmpty ? Icons.mic : Icons.send_rounded, key: ValueKey(ctl.text.trim().isEmpty), color: Colors.white),
                    ),
                    onPressed: ctl.text.trim().isEmpty
                        ? () => ScaffoldMessenger.of(c).showSnackBar(const SnackBar(content: Text('Голосові повідомлення — незабаром')))
                        : send,
                  )),
            ]),
          ),
        ),
      ]),
    );
  }
}
