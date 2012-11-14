function [] = generate_gif_for_animation( movie_frames )
%GENERATE_GIF_FOR_ANIMATION 通过Movie帧生成GIF动画
%   movie_frames是animation_response_score生成的。
%   gif动画是无限循环的
%
%   See also ANIMATION_RESPONSE_SCORE, MOVIE2GIF,
%   UTIL_PLOT_8S_INTO_DOTSGRAPH
%
%   蒲江波 2009年11月24日

% 获取movie的大小，设置movie窗口使之合适(第一帧=所有帧)
[h w p] = size( movie_frames(1).cdata );
hf = figure;

% 重设回放窗口大小
set(hf, 'position', [0 0 w h]);
axis off

movie(hf, movie_frames, 1, 30, [0 0 0 0]);

% 生成GIF
[filename pathname] = uiputfile('*.gif', 'The animated gif filename');
movie2gif(movie_frames, [pathname filename]);
end

