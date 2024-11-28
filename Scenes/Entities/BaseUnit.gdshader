shader_type canvas_item;

uniform float border_size : hint_range(1.0, 10.0) = 2.0; // Épaisseur de la bordure
uniform vec4 border_color : hint_color = vec4(1.0, 0.0, 0.0, 1.0); // Couleur de la bordure

void fragment() {
    // Taille et coordonnées UV normales
    vec2 size = vec2(SCREEN_PIXEL_SIZE.x, SCREEN_PIXEL_SIZE.y);
    vec2 uv = FRAGCOORD.xy / size;

    // Définir les limites de la bordure
    float left = border_size / size.x;
    float right = 1.0 - left;
    float top = border_size / size.y;
    float bottom = 1.0 - top;

    // Si dans la bordure (gauche/droite/haut/bas)
    if (uv.x < left || uv.x > right || uv.y < top || uv.y > bottom) {
        COLOR = border_color;
    } else {
        discard; // Ignore les pixels qui ne sont pas dans la bordure
    }
}
