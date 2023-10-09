import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_metronome/metronome.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
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
  final _metronome = Metronome(maxSpeed: 260);
  TextEditingController _bpmController = TextEditingController();

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
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

  void _updateBPM() {
    var inputValue = double.tryParse(_bpmController.text);
    if (inputValue != null) _metronome.setBPM(inputValue);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Metrônomo'),
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
      child: AnimatedBuilder(
        animation: _metronome.bpmNotifier,
        builder: (context, child) {
          return Slider(
            // label: '${_metronome.bpmNotifier.value}',
            value: _metronome.bpmNotifier.value,
            divisions: (_metronome.maxSpeed - _metronome.minSpeed).toInt(),
            max: _metronome.maxSpeed,
            min: _metronome.minSpeed,
            onChanged: (value) {
              var result = _metronome.setBPM(value);

              if (result) {
                _bpmController.text = value.toString();
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildCompassList() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(
            16.0,
            16.0,
            16.0,
            0.0,
          ),
          child: Text(
            'Batidas',
          ),
        ),
        Container(
          height: 60,
          child: AnimatedBuilder(
            animation: _metronome.compassoNotifier,
            builder: (context, child) {
              return ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                separatorBuilder: (context, index) => SizedBox(width: 12.0),
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                itemCount: _metronome.compassos.length,
                itemBuilder: (context, index) {
                  var compasso = _metronome.compassos[index];
                  var isSelected =
                      compasso == _metronome.compassoNotifier.value;
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
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.onPrimary
                                      : Theme.of(context).colorScheme.onSurface,
                                ),
                      ),
                    ),
                  );
                },
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
        onTap: () {
          if (_metronome.isPlaying) {
            _animationController.reverse();
            _metronome.stop();
          } else {
            _animationController.forward();
            _metronome.start();
          }
        },
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
                onPressed: () {
                  var result =
                      _metronome.setBPM(_metronome.bpmNotifier.value - 1);
                  if (result) {
                    _bpmController.text =
                        _metronome.bpmNotifier.value.toString();
                  }
                },
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
              onChanged: (value) => _updateBPM(),
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
                onPressed: () {
                  var result =
                      _metronome.setBPM(_metronome.bpmNotifier.value + 1);
                  if (result) {
                    _bpmController.text =
                        _metronome.bpmNotifier.value.toString();
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSongTile() {
    return ListTile(
      title: Text('Áudio'),
      leading: Icon(Icons.audiotrack_rounded),
      trailing: Icon(Icons.navigate_next),
      subtitle: AnimatedBuilder(
        animation: _metronome.metronomeSoundNotifier,
        builder: (context, child) {
          var value = _metronome.metronomeSoundNotifier.value;
          return Text(
            value.folder,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Theme.of(context).colorScheme.primary),
          );
        },
      ),
      onTap: () {
        var options = [
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
        // DsBottomSheet.showList<MetronomeSound>(
        //   context: context,
        //   items: options,
        //   getTitle: (item, index) {
        //     return options[index].folder;
        //   },
        //   getIcon: (item) {
        //     return Icon(Icons.music_note);
        //   },
        //   onTap: (item, index) {
        //     _metronome.setSound(options[index]);
        //   },
        // );
      },
    );
  }

  Widget _buildHitsIndicator() {
    return Container(
      margin: EdgeInsets.all(16.0),
      height: 12,
      alignment: Alignment.center,
      child: AnimatedBuilder(
        animation: _metronome.compassoNotifier,
        builder: (context, child) {
          return AnimatedBuilder(
            animation: _metronome.bitTimeNotifier,
            builder: (context, child) {
              var bitTime = _metronome.bitTimeNotifier.value;
              return ListView.separated(
                separatorBuilder: (context, index) => SizedBox(width: 12.0),
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                itemCount: _metronome.compassoNotifier.value,
                itemBuilder: (context, index) {
                  var isSelected = (index + 1) == bitTime;
                  return CircleAvatar(
                    radius: 6,
                    backgroundColor: isSelected
                        ? index == 0
                            ? Theme.of(context).colorScheme.error
                            : Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outlineVariant,
                  );
                },
              );
            },
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
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.0),
          topRight: Radius.circular(24.0),
        ),
      ),
      child: SafeArea(
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: Material(
            color: Colors.transparent,
            child: ExpansionTile(
              title: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.settings),
                title: Text('Configurações'),
              ),
              children: [
                _buildCompassList(),
                _buildSongTile(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}