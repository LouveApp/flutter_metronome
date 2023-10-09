import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
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

  final List<MetronomeSound> _soundsOptions = const [
    MetronomeSound.bell,
    MetronomeSound.clicks,
    MetronomeSound.cowbells,
    MetronomeSound.digital,
    MetronomeSound.pings,
    MetronomeSound.seiko,
    MetronomeSound.sticks,
    MetronomeSound.vegas,
    MetronomeSound.yamaha,
  ];

  final TextEditingController _bpmController = TextEditingController();

  late AnimationController _animationController;

  int? _beatIndex;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _metronome = Metronome(
      maxSpeed: 260,
      onBeat: (index) {
        setState(() {
          _beatIndex = index;
        });
      },
    );

    var initialBPM = 120.0;
    _bpmController.text = initialBPM.toString();
    _metronome.setBPM(initialBPM);
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
            child: CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Column(
                    children: <Widget>[
                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildBpmField(context),
                              const SizedBox(height: 16),
                              _buildPlayButton(),
                            ],
                          ),
                        ),
                      ),
                      _buildHitsIndicator(),
                    ],
                  ),
                )
              ],
            ),
          ),
          _buildBpmSlider(),
        ],
      ),
    );
  }

  Widget _buildBpmSlider() {
    return RotatedBox(
      quarterTurns: -1,
      child: Slider(
        value: _metronome.bpm,
        divisions: (_metronome.maxSpeed - _metronome.minSpeed).toInt(),
        max: _metronome.maxSpeed,
        min: _metronome.minSpeed,
        onChanged: _setBPM,
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
        Container(
          height: 60,
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            separatorBuilder: (context, index) => SizedBox(width: 12.0),
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            physics: ClampingScrollPhysics(),
            itemCount: _hitsOptions.length,
            itemBuilder: (context, index) {
              var compasso = _hitsOptions[index];
              var isSelected = compasso == _metronome.hits;
              return CircleAvatar(
                backgroundColor: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.surfaceVariant,
                child: IconButton(
                  onPressed: () {
                    _metronome.setHits(compasso);
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
            progress: _animationController,
            size: 60,
          ),
        ),
      ),
    );
  }

  void _play() {
    if (_metronome.isPlaying) {
      _animationController.reverse();
      _metronome.stop();
      setState(() {
        _beatIndex = null;
      });
    } else {
      _animationController.forward();
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
                icon: Icon(Icons.remove),
                onPressed: () => _setBPM(_metronome.bpm - 1),
              ),
            ),
          ),
          SizedBox(width: 16.0),
          Expanded(
            flex: 2,
            child: TextFormField(
              controller: _bpmController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              autovalidateMode: AutovalidateMode.always,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineLarge,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'(^-?\d*\.?\d*)'))
              ],
              validator: (value) {
                if (double.tryParse(value ?? '') == null) {
                  return 'min: ${_metronome.minSpeed}, max: ${_metronome.maxSpeed}';
                }
                var dbValue = double.parse(value!);
                if (dbValue < _metronome.minSpeed ||
                    dbValue > _metronome.maxSpeed) {
                  return 'min: ${_metronome.minSpeed}, max: ${_metronome.maxSpeed}';
                }
                return null;
              },
              decoration: InputDecoration(border: InputBorder.none),
              onChanged: (value) {
                var inputValue = double.tryParse(_bpmController.text);
                if (inputValue != null) _setBPM(inputValue);
              },
            ),
          ),
          SizedBox(width: 16.0),
          Expanded(
            flex: 1,
            child: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.surface,
              child: IconButton(
                color: Theme.of(context).colorScheme.primary,
                icon: Icon(Icons.add),
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
      title: Text('Sound'),
      leading: Icon(Icons.audiotrack_rounded),
      trailing: Text('${selectedIndex + 1}/${_soundsOptions.length}'),
      subtitle: Text(
        _metronome.sound.folder,
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

  Widget _buildHitsIndicator() {
    return Container(
      margin: const EdgeInsets.all(16.0),
      height: 12,
      alignment: Alignment.center,
      child: ListView.separated(
        separatorBuilder: (context, index) => const SizedBox(width: 12.0),
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
        itemCount: _metronome.hits,
        itemBuilder: (context, index) {
          var isSelected = (index + 1) == _beatIndex;
          return CircleAvatar(
            radius: 6,
            backgroundColor: isSelected
                ? index == 0
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
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24.0),
          topRight: Radius.circular(24.0),
        ),
      ),
      child: Material(
        color: Theme.of(context).colorScheme.outlineVariant,
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
