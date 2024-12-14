shader_type canvas_item;

// Uniformes configurables
uniform vec4 border_color = vec4(1.0, 0.0, 0.0, 1.0); // Couleur de la bordure
uniform float border_width = 2.0;                    // Largeur de la bordure
uniform float dash_length = 10.0;                    // Longueur des tirets
uniform float gap_length = 5.0;                      // Longueur des espaces entre les tirets

// Taille de l'objet (doit être passée depuis le code ou configurée)
uniform vec2 size = vec2(100.0, 100.0);              // Par défaut : 100x100

void fragment() {
    // Calculer la distance à chaque bord
    float dist_to_left = FRAGCOORD.x;
    float dist_to_right = size.x - FRAGCOORD.x;
    float dist_to_top = FRAGCOORD.y;
    float dist_to_bottom = size.y - FRAGCOORD.y;

    // Trouver la distance minimale pour déterminer si on est sur un bord
    float dist_to_edge = min(min(dist_to_left, dist_to_right), min(dist_to_top, dist_to_bottom));

    // Dessiner uniquement si on est dans la bordure
    if (dist_to_edge > border_width || dist_to_edge < 0.0) {
        discard;
    }

    // Calculer le motif en pointillés
    float dash_pattern = mod(FRAGCOORD.x + FRAGCOORD.y, dash_length + gap_length);
    if (dash_pattern > dash_length) {
        discard;
    }

    // Appliquer la couleur de la bordure
    COLOR = border_color;
}
