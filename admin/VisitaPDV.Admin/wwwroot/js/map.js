window.farmaciaMap = {
    map: null,
    marker: null,
    circle: null,
    dotNetRef: null,
    defaultLat: -0.1807,
    defaultLng: -78.4678,

    init: function (dotNetRef, lat, lng, radius) {
        this.dotNetRef = dotNetRef;

        // Clean up if already initialized
        if (this.map) {
            try {
                this.map.remove();
            } catch (e) {
                console.error("Error destroying map:", e);
            }
            this.map = null;
            this.marker = null;
            this.circle = null;
        }

        var isZero = Math.abs(lat) < 0.000001 && Math.abs(lng) < 0.000001;
        var startLat = isZero ? this.defaultLat : lat;
        var startLng = isZero ? this.defaultLng : lng;

        this.map = L.map('farmacia-map').setView([startLat, startLng], 15);

        L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
            attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
        }).addTo(this.map);

        if (!isZero) {
            this.createMarkerAndCircle(startLat, startLng, radius);
        }

        var self = this;
        this.map.on('click', function (e) {
            var clickedLat = e.latlng.lat;
            var clickedLng = e.latlng.lng;
            self.updateMarkerAndCircle(clickedLat, clickedLng, radius);
            self.notifyBlazor(clickedLat, clickedLng);
        });

        // Trigger resize after rendering completes
        setTimeout(function() {
            if (self.map) {
                self.map.invalidateSize();
            }
        }, 150);
    },

    createMarkerAndCircle: function (lat, lng, radius) {
        var self = this;
        this.marker = L.marker([lat, lng], { draggable: true }).addTo(this.map);
        this.circle = L.circle([lat, lng], {
            radius: radius || 100,
            color: '#00A651',
            fillColor: '#00A651',
            fillOpacity: 0.2
        }).addTo(this.map);

        this.marker.on('dragend', function (e) {
            var pos = self.marker.getLatLng();
            self.circle.setLatLng(pos);
            self.notifyBlazor(pos.lat, pos.lng);
        });
    },

    updateMarkerAndCircle: function (lat, lng, radius) {
        if (!this.map) return;

        var isZero = Math.abs(lat) < 0.000001 && Math.abs(lng) < 0.000001;
        if (isZero) {
            if (this.marker) {
                this.map.removeLayer(this.marker);
                this.marker = null;
            }
            if (this.circle) {
                this.map.removeLayer(this.circle);
                this.circle = null;
            }
            this.map.setView([this.defaultLat, this.defaultLng], 15);
            return;
        }

        if (!this.marker) {
            this.createMarkerAndCircle(lat, lng, radius);
        } else {
            var newLatLng = new L.LatLng(lat, lng);
            this.marker.setLatLng(newLatLng);
            this.circle.setLatLng(newLatLng);
            if (radius) {
                this.circle.setRadius(radius);
            }
        }
    },

    update: function (lat, lng, radius) {
        if (!this.map) return;
        this.updateMarkerAndCircle(lat, lng, radius);
        var isZero = Math.abs(lat) < 0.000001 && Math.abs(lng) < 0.000001;
        if (!isZero) {
            this.map.setView([lat, lng], this.map.getZoom());
        }
    },

    searchAddress: function (address) {
        if (!address || !this.map) return;
        var self = this;
        var url = 'https://nominatim.openstreetmap.org/search?format=json&q=' + encodeURIComponent(address) + '&limit=1';

        fetch(url)
            .then(function (response) { return response.json(); })
            .then(function (data) {
                if (data && data.length > 0) {
                    var lat = parseFloat(data[0].lat);
                    var lng = parseFloat(data[0].lon);
                    self.update(lat, lng, null);
                    self.notifyBlazor(lat, lng);
                } else {
                    alert('No se encontró la dirección.');
                }
            })
            .catch(function (error) {
                console.error('Error in geocoding:', error);
                alert('Ocurrió un error al buscar la dirección.');
            });
    },

    getCurrentLocation: function () {
        var self = this;
        if (!navigator.geolocation) {
            alert('La geolocalización no está soportada por este navegador.');
            return;
        }

        navigator.geolocation.getCurrentPosition(
            function (position) {
                var lat = position.coords.latitude;
                var lng = position.coords.longitude;
                self.update(lat, lng, null);
                self.notifyBlazor(lat, lng);
            },
            function (error) {
                console.warn('Error al obtener geolocalización:', error);
                alert('No se pudo obtener la ubicación actual. Verifique los permisos del navegador.');
            },
            { enableHighAccuracy: true, timeout: 10000, maximumAge: 0 }
        );
    },

    notifyBlazor: function (lat, lng) {
        if (this.dotNetRef) {
            this.dotNetRef.invokeMethodAsync('UpdateCoordinates', lat, lng);
        }
    },

    invalidateSize: function () {
        if (this.map) {
            this.map.invalidateSize();
        }
    }
};
