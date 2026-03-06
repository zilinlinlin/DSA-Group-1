%% load variables
load("data\long log.mat")

%% plot map
geoplot(Position.latitude, Position.longitude);
geobasemap streets

%% load audio
clc

[signal, Fs] = audioread('data\long log.m4a');
t = (0:length(signal)-1) / Fs;

%% plot audio
stem(t, signal(:,1), 'filled', 'MarkerFaceColor', 'red');
xlabel('Time (seconds)');
ylabel('Amplitude');
title('Stem Plot of Audio Signal');
grid on;

%% test
%testing again