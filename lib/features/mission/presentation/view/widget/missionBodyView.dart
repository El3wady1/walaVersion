import 'package:card_loading/card_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saladafactory/features/mission/data/model/missionModel.dart';
import 'package:saladafactory/features/mission/presentation/controller/missionCubit.dart';
import 'package:saladafactory/features/mission/presentation/controller/missionState.dart';

class MissionBodyView extends StatelessWidget {
  const MissionBodyView({super.key});

  static const Color primaryColor = Color(0xFF74826A);
  static const Color accentColor = Color(0xFFEDBE2C);
  static const Color secondaryColor = Color(0xFFCDBCA2);
  static const Color backgroundColor = Color(0xFFF3F4EF);
  static const Color textColor = Color(0xFF333333);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      body: RefreshIndicator(
        color: primaryColor,
        onRefresh: () => context.read<MissionCubit>().refreshMission(),
        child: BlocBuilder<MissionCubit, MissionState>(
          builder: (context, state) {
            if (state is LoadingMissionState) {
              return ListView.builder(
                itemCount: 5,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 25.0,
                      vertical: 5,
                    ),
                    child: CardLoading(
                      cardLoadingTheme: CardLoadingTheme(
                        colorOne: secondaryColor.withOpacity(0.3),
                        colorTwo: secondaryColor.withOpacity(0.2),
                      ),
                      height: 55,
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                    ),
                  );
                },
              );
            }

            if (state is LoadedMissionState) {
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: state.missions.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) =>
                    _buildGuideItem(state.missions[index], index),
              );
            }

            if (state is FailMissionState) {
              return Center(child: Text(state.error));
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildGuideItem(MissionModel item, int index) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getItemColor(index).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(Icons.flag, size: 20, color: _getItemColor(index)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.info,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${index + 1}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: _getItemColor(index),
            ),
          ),
        ],
      ),
    );
  }

  Color _getItemColor(int index) {
    List<Color> colors = [primaryColor, accentColor, secondaryColor];
    return colors[index % colors.length];
  }
}
