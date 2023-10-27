import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_metronome/entities/metronome_sound.dart';
import 'package:flutter_metronome/flutter_metronome.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Metronome',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  late final Metronome _metronome;
  final List<int> _hitsOptions = [1, 2, 3, 4, 5, 6, 7, 8];
  final List<MetronomeSound> _soundsOptions = [
    MetronomeSounds.bell,
    MetronomeSounds.clicks,
    MetronomeSounds.cowbells,
    MetronomeSounds.digital,
    MetronomeSounds.pings,
    MetronomeSounds.seiko,
    MetronomeSounds.sticks,
    MetronomeSounds.vegas,
    MetronomeSounds.yamaha,
  ];
  final TextEditingController _bpmController = TextEditingController();
  late AnimationController _iconAnimationController;
  int? _beatIndex;

  @override
  void initState() {
    super.initState();

    _iconAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _metronome = Metronome(
      maxBpm: 400,
      minBpm: 40,
      beats: 4,
      initialBpm: 120.0,
      sound: MetronomeSounds.digital,
      onBeat: (index) {
        setState(() {
          _beatIndex = index;
        });
      },
    );

    _setBPM(120.0);
  }

  @override
  void dispose() {
    _bpmController.dispose();
    _metronome.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Metronome'),
      ),
      bottomNavigationBar: _buildBottom(),
      body: Row(
        children: [
          Expanded(
            child: _buildBody(context),
          ),
          _buildBpmSlider(),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildBpmField(context),
                  const SizedBox(height: 16.0),
                  _buildPlayButton(),
                ],
              ),
            ),
          ),
        ),
        _buildBeatIndicator(),
      ],
    );
  }

  Widget _buildBpmSlider() {
    var divisions = (_metronome.maxBpm - _metronome.minBpm).toInt();
    return RotatedBox(
      quarterTurns: -1,
      child: Slider(
        value: _metronome.bpm,
        divisions: divisions,
        max: _metronome.maxBpm,
        min: _metronome.minBpm,
        onChanged: (value) {
          _setBPM(value.toInt().toDouble());
        },
      ),
    );
  }

  void _setBPM(double value) {
    setState(() {
      var result = _metronome.setBPM(value);
      if (result && value.toString() != _bpmController.text) {
        _bpmController.text = value.toString();
      }
    });
  }

  Widget _buildBeatList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            16.0,
            16.0,
            16.0,
            0.0,
          ),
          child: Text('Beat', style: Theme.of(context).textTheme.titleMedium),
        ),
        SizedBox(
          height: 60,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            separatorBuilder: (context, index) => const SizedBox(width: 12.0),
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
            itemCount: _hitsOptions.length,
            itemBuilder: (context, index) {
              var compasso = _hitsOptions[index];
              var isSelected = compasso == _metronome.beats;
              return CircleAvatar(
                backgroundColor: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.surface,
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      _metronome.setBeats(compasso);
                    });
                  },
                  icon: Text(
                    compasso.toString(),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: isSelected
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPlayButton() {
    return Card(
      child: InkWell(
        onTap: _play,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: AnimatedIcon(
            icon: AnimatedIcons.play_pause,
            progress: _iconAnimationController,
            size: 60,
          ),
        ),
      ),
    );
  }

  void _play() {
    if (_metronome.isPlaying) {
      _iconAnimationController.reverse();
      _metronome.stop();
      setState(() {
        _beatIndex = null;
      });
    } else {
      _iconAnimationController.forward();
      _metronome.start();
    }
  }

  Widget _buildBpmField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.surface,
              child: IconButton(
                color: Theme.of(context).colorScheme.primary,
                icon: const Icon(Icons.remove),
                onPressed: () => _setBPM(_metronome.bpm - 1),
              ),
            ),
          ),
          const SizedBox(width: 16.0),
          Expanded(
            flex: 2,
            child: TextFormField(
              controller: _bpmController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              autovalidateMode: AutovalidateMode.always,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineLarge,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'(^-?\d*\.?\d*)'))
              ],
              validator: (value) {
                if (double.tryParse(value ?? '') == null) {
                  return 'min: ${_metronome.minBpm}, max: ${_metronome.maxBpm}';
                }
                var dbValue = double.parse(value!);
                if (dbValue < _metronome.minBpm ||
                    dbValue > _metronome.maxBpm) {
                  return 'min: ${_metronome.minBpm}, max: ${_metronome.maxBpm}';
                }
                return null;
              },
              decoration: const InputDecoration(border: InputBorder.none),
              onChanged: (value) {
                var inputValue = double.tryParse(_bpmController.text);
                if (inputValue != null) _setBPM(inputValue);
              },
            ),
          ),
          const SizedBox(width: 16.0),
          Expanded(
            flex: 1,
            child: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.surface,
              child: IconButton(
                color: Theme.of(context).colorScheme.primary,
                icon: const Icon(Icons.add),
                onPressed: () => _setBPM(_metronome.bpm + 1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSongTile() {
    var selectedIndex =
        _soundsOptions.indexWhere((element) => element == _metronome.sound);

    return ListTile(
      title: const Text('Sound'),
      leading: const Icon(Icons.audiotrack_rounded),
      trailing: Text('${selectedIndex + 1}/${_soundsOptions.length}'),
      subtitle: Text(
        _metronome.sound.name ?? ' - ',
        style: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(color: Theme.of(context).colorScheme.primary),
      ),
      onTap: () {
        MetronomeSound newSound;
        if (selectedIndex < (_soundsOptions.length - 1)) {
          newSound = _soundsOptions[selectedIndex + 1];
        } else {
          newSound = _soundsOptions.first;
        }

        setState(() {
          _metronome.setSound(newSound);
        });
      },
    );
  }

  Widget _buildBeatIndicator() {
    return Container(
      margin: const EdgeInsets.all(16.0),
      height: 14,
      alignment: Alignment.center,
      child: ListView.separated(
        separatorBuilder: (context, index) => const SizedBox(width: 8.0),
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
        itemCount: _metronome.beats,
        itemBuilder: (context, index) {
          var isSelected = (index + 1) == _beatIndex;
          return Icon(
            Icons.circle,
            size: 14,
            color: isSelected
                ? _beatIndex == 1
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outlineVariant,
          );
        },
      ),
    );
  }

  Widget _buildBottom() {
    return Container(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.0),
          topRight: Radius.circular(24.0),
        ),
      ),
      child: Material(
        color: Theme.of(context).colorScheme.primaryContainer,
        child: SafeArea(
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              title: const ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.settings),
                title: Text('Settings'),
              ),
              children: [
                _buildBeatList(),
                _buildSongTile(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
