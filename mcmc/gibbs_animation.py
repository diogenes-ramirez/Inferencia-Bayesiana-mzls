"""Render with Manim Community 0.22.0 and Python 3.13:

uv tool run --from manim==0.22.0 --python 3.13 manim render mcmc/gibbs_animation.py GibbsSweep --fps 24 --resolution 1280,720 --format mp4

The project manim.cfg routes the rendered asset into media/.
"""

from manim import *


class GibbsSweep(Scene):
    def construct(self):
        navy = "#12304a"
        blue = "#356d9a"
        orange = "#d95f02"
        self.camera.background_color = "#ffffff"

        title = Text("Una iteración del muestreador de Gibbs", color=navy, font_size=34)
        title.to_edge(UP, buff=0.35)
        self.play(Write(title), run_time=1)

        axes = Axes(
            x_range=[-3, 3, 1], y_range=[-3, 3, 1],
            x_length=6.0, y_length=6.0,
            axis_config={"color": navy, "include_numbers": True, "font_size": 18},
            tips=False,
        ).shift(LEFT * 2.55 + DOWN * 0.35)
        x_label = axes.get_x_axis_label("x", edge=RIGHT, direction=RIGHT, buff=0.15)
        y_label = axes.get_y_axis_label("y", edge=UP, direction=UP, buff=0.15)
        rho = 0.8
        covariance = np.array([[1, rho], [rho, 1]])
        eigenvalues, eigenvectors = np.linalg.eigh(covariance)
        contours = VGroup()
        angles = np.linspace(0, TAU, 241)
        unit_circle = np.vstack((np.cos(angles), np.sin(angles)))
        for scale in [2.5, 2.0, 1.5, 1.0, 0.55]:
            data_points = scale * eigenvectors @ np.diag(np.sqrt(eigenvalues)) @ unit_circle
            contour = VMobject(color=blue, stroke_width=2)
            contour.set_points_as_corners([axes.c2p(x, y) for x, y in data_points.T])
            contours.add(contour)
        rho_label = Text("ρ = 0.8", color=blue, font_size=21)
        rho_label.next_to(axes, UP, buff=0.12).align_to(axes, LEFT)
        # Use the correlated Gaussian geometry as the dominant visual; the grid remains quiet.
        self.play(Create(axes), FadeIn(x_label), FadeIn(y_label), FadeIn(rho_label), run_time=1.2)
        self.play(LaggedStart(*[Create(item) for item in contours], lag_ratio=0.12), run_time=1.5)

        current = axes.c2p(-1.35, -0.85)
        x_draw = axes.c2p(-0.30, -0.85)
        next_point = axes.c2p(-0.30, 0.30)
        point = Dot(current, radius=0.09, color=orange)
        self.play(FadeIn(point, scale=0.5), run_time=0.6)

        annotation = VGroup(
            Text("1. Sortear x | y", color=navy, font_size=25),
            Text("x | y ~ N(ρy, 1 − ρ²)", color=blue, font_size=22),
        ).arrange(DOWN, aligned_edge=LEFT, buff=0.25).to_edge(RIGHT, buff=0.6).shift(UP * 1.45)
        self.play(FadeIn(annotation, shift=LEFT * 0.15), run_time=0.7)
        horizontal = DashedLine(current, x_draw, color=orange, stroke_width=4)
        self.play(Create(horizontal), point.animate.move_to(x_draw), run_time=2.2)

        second = VGroup(
            Text("2. Sortear y | x", color=navy, font_size=25),
            Text("y | x ~ N(ρx, 1 − ρ²)", color=blue, font_size=22),
        ).arrange(DOWN, aligned_edge=LEFT, buff=0.25).move_to(annotation)
        self.play(Transform(annotation, second), run_time=0.7)
        vertical = DashedLine(x_draw, next_point, color=blue, stroke_width=4)
        self.play(Create(vertical), point.animate.move_to(next_point), run_time=2.2)

        self.play(Transform(annotation, VGroup(
            Text("Un paso completo", color=navy, font_size=27),
            Text("x nuevo → y nuevo", color=blue, font_size=23),
        ).arrange(DOWN, aligned_edge=LEFT, buff=0.25).move_to(annotation)), run_time=0.7)
        self.wait(4.2)
