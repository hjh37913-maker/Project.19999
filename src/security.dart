import 'package:flutter/material.dart';
import 'main.dart';

String? appPin;

class LockGate extends StatefulWidget {
  final Widget child;
  const LockGate({super.key, required this.child});
  @override
  State<LockGate> createState() => _LockGateState();
}

class _LockGateState extends State<LockGate> with WidgetsBindingObserver {
  bool locked = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState s) {
    if (s == AppLifecycleState.paused && appPin != null) setState(() => locked = true);
  }

  @override
  Widget build(BuildContext c) => Stack(children: [
        widget.child,
        if (locked)
          Positioned.fill(
            child: PinPad(
              title: 'Введіть PIN-код',
              onDone: (p) {
                if (p != appPin) return false;
                setState(() => locked = false);
                return true;
              },
            ),
          ),
      ]);
}

class PinPad extends StatefulWidget {
  final String title;
  final bool Function(String) onDone;
  const PinPad({super.key, required this.title, required this.onDone});
  @override
  State<PinPad> createState() => _PinPadState();
}

class _PinPadState extends State<PinPad> {
  String pin = '';
  bool err = false;
  void tap(String d) {
    if (pin.length >= 4) return;
    setState(() {
      pin += d;
      err = false;
    });
    if (pin.length == 4) {
      final ok = widget.onDone(pin);
      if (!ok && mounted) setState(() {
            pin = '';
            err = true;
          });
    }
  }

  @override
  Widget build(BuildContext c) {
    final cs = Theme.of(c).colorScheme;
    Widget key(String t, {VoidCallback? f, IconData? i}) => Padding(
          padding: const EdgeInsets.all(8),
          child: SizedBox(
            width: 72, height: 72,
            child: t.isEmpty && i == null
                ? null
                : TextButton(
                    style: TextButton.styleFrom(shape: const CircleBorder(), backgroundColor: cs.surfaceContainerHighest),
                    onPressed: f ?? () => tap(t),
                    child: i != null ? Icon(i) : Text(t, style: const TextStyle(fontSize: 26)),
                  ),
          ),
        );
    return Scaffold(
      body: SafeArea(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.lock_rounded, size: 44, color: kBlue),
          const SizedBox(height: 14),
          Text(widget.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(err ? 'Невірний PIN-код' : ' ', style: TextStyle(color: cs.error)),
          const SizedBox(height: 14),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            for (var i = 0; i < 4; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.all(8),
                width: 16, height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i < pin.length ? kBlue : Colors.transparent,
                  border: Border.all(color: err ? cs.error : kBlue, width: 2),
                ),
              ),
          ]),
          const SizedBox(height: 24),
          for (final r in [['1', '2', '3'], ['4', '5', '6'], ['7', '8', '9']])
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [for (final d in r) key(d)]),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            key(''),
            key('0'),
            key('', i: Icons.backspace_outlined, f: () => setState(() => pin = pin.isEmpty ? '' : pin.substring(0, pin.length - 1))),
          ]),
        ]),
      ),
    );
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool online = true, hideText = false, screenshots = false;
  @override
  Widget build(BuildContext c) {
    final dark = themeMode.value == ThemeMode.dark;
    return Scaffold(
      appBar: AppBar(title: const Text('Налаштування', style: TextStyle(fontWeight: FontWeight.w800))),
      body: ListView(children: [
        const ListTile(
          contentPadding: EdgeInsets.all(18),
          leading: CircleAvatar(radius: 30, backgroundColor: kBlue, child: Text('О', style: TextStyle(color: Colors.white, fontSize: 24))),
          title: Text('Олександр Гідний', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
          subtitle: Text('+380 •• ••• •• ••\nПідтверджено через Дію'),
          isThreeLine: true,
        ),
        const Divider(),
        SwitchListTile(
          secondary: const Icon(Icons.dark_mode_outlined),
          title: const Text('Темна тема'),
          value: dark,
          onChanged: (v) {
            themeMode.value = v ? ThemeMode.dark : ThemeMode.light;
            setState(() {});
          },
        ),
        ListTile(
          leading: const Icon(Icons.pin_outlined),
          title: const Text('PIN-код'),
          subtitle: Text(appPin == null ? 'Вимкнено' : 'Застосунок блокується при виході'),
          trailing: Icon(appPin == null ? Icons.chevron_right : Icons.check_circle, color: appPin == null ? null : kBlue),
          onTap: () {
            if (appPin != null) {
              setState(() => appPin = null);
              return;
            }
            Navigator.push(
                c,
                fade(PinPad(
                  title: 'Створіть PIN-код',
                  onDone: (p) {
                    appPin = p;
                    Navigator.pop(c);
                    return true;
                  },
                ))).then((_) => setState(() {}));
          },
        ),
        const Divider(),
        const Padding(padding: EdgeInsets.fromLTRB(18, 10, 18, 4), child: Text('Приватність', style: TextStyle(fontWeight: FontWeight.w700))),
        SwitchListTile(title: const Text('Показувати «в мережі»'), value: online, onChanged: (v) => setState(() => online = v)),
        SwitchListTile(title: const Text('Сповіщення без тексту'), value: hideText, onChanged: (v) => setState(() => hideText = v)),
        SwitchListTile(title: const Text('Дозволити знімки екрана'), value: screenshots, onChanged: (v) => setState(() => screenshots = v)),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.info_outline),
          title: const Text('Про застосунок'),
          onTap: () => showAboutDialog(context: c, applicationName: 'Є-Гідність', applicationVersion: '1.1.0', children: const [Text('Безпечний український месенджер.')]),
        ),
      ]),
    );
  }
}
