geobasemap streets

Position.Timestamp   = datetime(Position.Timestamp);
Acceleration.Timestamp = datetime(Acceleration.Timestamp);
Orientation.Timestamp  = datetime(Orientation.Timestamp);

% round timestamps
Position.Timestamp = dateshift(Position.Timestamp,'start','second');
Acceleration.Timestamp = dateshift(Acceleration.Timestamp,'start','second');
Orientation.Timestamp  = dateshift(Orientation.Timestamp,'start','second');
%calculate magnitude
Orientation.gmag = sqrt(Orientation.X.^2 + Orientation.Y.^2 + Orientation.Z.^2);
Acceleration.accmag = sqrt(Acceleration.X.^2 + Acceleration.Y.^2 + Acceleration.Z.^2);

PositionResampled = retime(Position, 'secondly', 'mean');
AccelerationResampled = retime(Acceleration(:, "accmag"), 'secondly', 'mean');
dataTable = synchronize(Position, Acceleration(:, "accmag"), Orientation(:, "gmag"), 'intersection');
shakeThresh = 50;
spinThresh  = 200; %test value
stillThresh = 5; %test value

shake = (dataTable.accmag > shakeThresh);
spin = (dataTable.gmag > spinThresh);
still = (dataTable.accmag < stillThresh);

% Plot spin, shake and still detected locations
hold on;
geoscatter(dataTable.latitude(shake), dataTable.longitude(shake), 50, 'r', 'filled')
geoplot(Position.latitude, Position.longitude);
geoscatter(dataTable.latitude(spin), dataTable.longitude(spin), 50, 'b', 'filled')
geoscatter(dataTable.latitude(still), dataTable.longitude(still), 50, 'y', 'filled')
title('Shake/Spin Detected Locations')

