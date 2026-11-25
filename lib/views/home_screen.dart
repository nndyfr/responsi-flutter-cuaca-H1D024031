import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/weather_model.dart';
import '../viewmodels/view_state.dart';
import '../viewmodels/weather_viewmodel.dart';
import 'search_screen.dart';
import 'weather_icons.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openSearch(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SearchScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<WeatherViewModel>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aplikasi Cuaca', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: vm.location != null
            ? [
                IconButton(
                  icon: const Icon(Icons.search),
                  tooltip: 'Cari kota',
                  onPressed: () => _openSearch(context),
                ),
              ]
            : [],
      ),
      body: _buildBody(context, vm),
    );
  }

  Widget _buildBody(BuildContext context, WeatherViewModel vm) {
    if (vm.location == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.location_city, size: 64, color: Colors.blue.shade700),
              ),
              const SizedBox(height: 24),
              Text(
                'Belum ada kota dipilih',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.blue.shade900),
              ),
              const SizedBox(height: 8),
              Text(
                'Silakan cari dan pilih kota untuk melihat informasi cuaca terkini.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => _openSearch(context),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(Icons.search),
                label: const Text('Cari Kota', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      );
    }

    if (vm.state == ViewState.loading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.blue),
      );
    }

    if (vm.state == ViewState.error) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
              const SizedBox(height: 16),
              Text(vm.errorMessage, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: vm.loadWeather,
                style: FilledButton.styleFrom(backgroundColor: Colors.blue.shade700),
                icon: const Icon(Icons.refresh),
                label: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
      );
    }

    final weather = vm.weather;
    if (weather == null) {
      return const Center(child: Text('Data cuaca kosong'));
    }
    return _WeatherContent(vm: vm, weather: weather);
  }
}

class _WeatherContent extends StatelessWidget {
  final WeatherViewModel vm;
  final WeatherData weather;
  const _WeatherContent({required this.vm, required this.weather});

  static const _hari = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final c = weather.current;
    final today = weather.daily.first;

    return RefreshIndicator(
      color: Colors.blue.shade700,
      onRefresh: vm.loadWeather,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Kartu Utama dengan Gradien Biru Menarik
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade800, Colors.blue.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_on, color: Colors.white70, size: 20),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          vm.location!.label,
                          style: text.titleLarge?.copyWith(color: Colors.white),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Icon(weatherIcon(c.weatherCode), size: 80, color: Colors.white),
                  const SizedBox(height: 12),
                  Text(
                    '${c.temperature.round()}°C',
                    style: text.displayMedium?.copyWith(
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    weatherDescription(c.weatherCode),
                    style: text.titleMedium?.copyWith(color: Colors.white70, fontSize: 18),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Judul Informasi Tambahan
          Text(
            'Informasi Cuaca Terkini',
            style: text.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.blue.shade900),
          ),
          const SizedBox(height: 12),

          // Grid Informasi Tambahan
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            children: [
              _InfoTile(Icons.thermostat, 'Terasa seperti', '${c.apparentTemperature.round()}°C', Colors.orange),
              _InfoTile(Icons.water_drop_outlined, 'Kelembapan', '${c.humidity}%', Colors.blue),
              _InfoTile(Icons.air, 'Kecepatan angin', '${c.windSpeed} km/j', Colors.teal),
              _InfoTile(Icons.umbrella_outlined, 'Peluang hujan', '${today.rainChance}%', Colors.indigo),
              _InfoTile(Icons.grain, 'Curah hujan', '${c.precipitation} mm', Colors.cyan),
            ],
          ),
          const SizedBox(height: 24),

          // Judul Perkiraan Harian
          Text(
            'Perkiraan ${weather.daily.length} Hari ke Depan',
            style: text.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.blue.shade900),
          ),
          const SizedBox(height: 12),

          // List Perkiraan Harian
          ...List.generate(weather.daily.length, (i) {
            final d = weather.daily[i];
            final nama = i == 0 ? 'Hari ini' : _hari[d.date.weekday - 1];
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withValues(alpha: 0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(weatherIcon(d.weatherCode), color: Colors.blue.shade700),
                ),
                title: Text(
                  '$nama, ${d.date.day}/${d.date.month}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${weatherDescription(d.weatherCode)} • Hujan ${d.rainChance}%',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
                trailing: Text(
                  '${d.maxTemp.round()}° / ${d.minTemp.round()}°',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.blue.shade800),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;
  const _InfoTile(this.icon, this.label, this.value, this.iconColor);

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue.shade50.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: text.bodySmall?.copyWith(color: Colors.grey.shade600), overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(value, style: text.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 15)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
