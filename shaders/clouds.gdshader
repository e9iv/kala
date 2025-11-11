shader_type canvas_item;

render_mode blend_sub;

uniform sampler2D noise_texture : filter_linear_mipmap, repeat_enable;
uniform float cloud_speed : hint_range(0.0, 1.0) = 0.05;
uniform float cloud_scale : hint_range(0.1, 10.0) = 2.0;
uniform float cloud_density : hint_range(0.0, 1.0) = 0.5;
uniform float cloud_sharpness : hint_range(0.0, 1.0) = 0.3;
uniform vec4 cloud_color : source_color = vec4(1.0, 1.0, 1.0, 0.8);

void fragment() {
    // Get UV coordinates
    vec2 uv = UV * cloud_scale;

    // Animate clouds over time
    vec2 animated_uv1 = uv + vec2(TIME * cloud_speed, TIME * cloud_speed * 0.5);
    vec2 animated_uv2 = uv * 1.5 + vec2(-TIME * cloud_speed * 0.7, TIME * cloud_speed * 0.3);

    // Sample noise texture with animated UVs
    float cloud_pattern = texture(noise_texture, animated_uv1).r;
    cloud_pattern += texture(noise_texture, animated_uv2).r * 0.5;

    // Normalize and adjust density
    cloud_pattern = cloud_pattern / 1.5;
    cloud_pattern = smoothstep(cloud_density - cloud_sharpness, cloud_density + cloud_sharpness, cloud_pattern);

    // Apply cloud color with alpha based on cloud pattern
    COLOR = vec4(cloud_color.rgb, cloud_color.a * cloud_pattern);
}
