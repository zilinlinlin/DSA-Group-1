geobasemap streets

Position.Timestamp   = datetime(Position.Timestamp);
Acceleration.Timestamp = datetime(Acceleration.Timestamp);
AngularVelocity.Timestamp  = datetime(AngularVelocity.Timestamp);

% round timestamps
Position.Timestamp = dateshift(Position.Timestamp,'start','second');
Acceleration.Timestamp = dateshift(Acceleration.Timestamp,'start','second');
AngularVelocity.Timestamp  = dateshift(AngularVelocity.Timestamp,'start','second');
%calculate magnitude
AngularVelocity.gmag = sqrt(AngularVelocity.X.^2 + AngularVelocity.Y.^2 + AngularVelocity.Z.^2);
Acceleration.accmag = sqrt(Acceleration.X.^2 + Acceleration.Y.^2 + Acceleration.Z.^2);

PositionResampled = retime(Position, 'secondly', 'mean');
AccelerationResampled = retime(Acceleration(:, "accmag"), 'secondly', 'mean');
dataTable = synchronize(Position, Acceleration(:, "accmag"), AngularVelocity(:, "gmag"), 'intersection');
shakeThresh = 70;
spinThresh  = 12; %test value
stillThresh = 0.01; %test value

shake = (dataTable.accmag > shakeThresh);
spin = (dataTable.gmag > spinThresh);
still = (dataTable.speed < stillThresh);

% Plot spin, shake and still detected locations
hold on;
geoscatter(dataTable.latitude(shake), dataTable.longitude(shake), 50, 'r', 'filled')
geoplot(Position.latitude, Position.longitude);
geoscatter(dataTable.latitude(spin), dataTable.longitude(spin), 50, 'b', 'filled')
geoscatter(dataTable.latitude(still), dataTable.longitude(still), 50, 'y', 'filled')
title('Shake/Spin Detected Locations')

