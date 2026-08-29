import 'package:flutter/material.dart';

enum FaceType { round, square, oval, heart }
enum SkinTone { white, tan }
enum UserGender { male, female }

class TryOnService {
  static String getFaceAsset(FaceType shape, SkinTone tone, UserGender gender) {
    // Definimos la ruta de la carpeta para facilitar cambios
    // Formato sugerido: face_male_round_white.png
    const basePath = 'assets/images/try_on';
    return '$basePath/face_${gender.name}_${shape.name}_${tone.name}.png';
  }

  static String getRecommendation(FaceType type) {
    switch (type) {
      case FaceType.round: 
        return "Las monturas rectangulares o cuadradas son perfectas para dar estructura y alargar visualmente tu rostro.";
      case FaceType.square: 
        return "Las gafas redondas u ovaladas ayudarán a suavizar los ángulos marcados de tu mandíbula y frente.";
      case FaceType.oval:
        return "¡Tienes suerte! Casi cualquier estilo de montura te queda bien. Prueba con algo atrevido.";
      case FaceType.heart:
        return "Las monturas tipo aviador o con la parte inferior más ancha equilibrarán la zona superior de tu rostro.";
      default:
        return "Este modelo se adapta perfectamente a tu fisonomía única.";
    }
  }

  // Recomendación de colores según tono de piel
  static String getColorAdvice(SkinTone tone) {
    switch (tone) {
      case SkinTone.white: return "Los colores oscuros o pasteles fríos resaltarán tu tono.";
      case SkinTone.tan: return "Los tonos dorados, carey y colores cálidos son tus mejores aliados.";
    }
  }
}
