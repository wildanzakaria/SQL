CREATE DATABASE spotify;
SELECT * FROM features;
SELECT * FROM streams;
DESCRIBE features;
DESCRIBE streams;
-- mengubah nama kolom `Release Date` menjadi "release_date" dengan tipe data date
ALTER TABLE streams
CHANGE `Release Date` release_date TEXT;
-- mengubah nama kolom `Streams (Billions)` menjadi "streams_billion"
ALTER TABLE streams
CHANGE `Streams (Billions)` streams_billion FLOAT;
-- judul lagu ed sheeran yang termasuk pada "Most Streamed Songs of All time on Spotify" 
SELECT song
FROM streams
WHERE Artist = 'Ed Sheeran';
-- lagu yang berawalan huruf a
SELECT song 
FROM streams
WHERE song LIKE 'A%';
-- judul lagu dan artist pada "Most Streamed Songs of All time on Spotify" yang memiliki streams lebih dari 1,5 billion release dan release pada tahun 2019
SELECT song, artist
FROM streams
WHERE streams_billion > 1.5
	AND release_date LIKE '%-19';
-- rata-rata streamers lagu dari artist ed sheeran dengan angka desimal dibelakang koma 2
SELECT artist, ROUND(AVG(streams_billion), 2) as streamers 
FROM streams
WHERE artist = 'Ed Sheeran'
GROUP BY artist;
-- rata-rata durasi lagu dari artist ed sheeran (menggabungkan 2 tabel streamers dan features)
SELECT artist, ROUND(AVG(duration), 2) as avg_duration
FROM streams AS s
INNER JOIN features AS f
ON s.song = f.name
WHERE Artist = 'Ed Sheeran';
-- top 5 lagu yang berdurasi paling lama
SELECT name AS song,
	duration
FROM features
ORDER BY duration DESC
LIMIT 5;
-- top 5 lagu yang berdurasi paling pendek
SELECT name AS song,
	duration
FROM features
ORDER BY duration ASC
LIMIT 5;
-- lagu ed sheeran yang berdurasi paling lama
SELECT song,
	MAX(duration) AS longest_duration
FROM streams AS s
INNER JOIN features AS f
ON s.song = f.name
WHERE artist = 'Ed Sheeran'
GROUP BY song
ORDER BY longest_duration DESC
LIMIT 1;
-- artist dan lagu yang berenergi paling tinggi
 SELECT artist,
	name AS song,
	MAX(energy) AS highest_energi
FROM streams AS s
INNER JOIN features AS f
ON s.song=f.name
GROUP BY artist, name
ORDER BY MAX(energy) DESC
LIMIT 1;
-- top 3 song untuk dance
SELECT name AS song,
	danceability
FROM features
ORDER BY 2 DESC
LIMIT 3;
-- total lagu yang bertangga nada mayor
SELECT COUNT(mode) AS total_mayor
FROM features
WHERE mode = 1;
-- rata-rata durasi dan energi lagu setiap artist
SELECT artist,
	ROUND(AVG(duration), 2) AS avg_duration,
    ROUND(AVG(energy), 2) AS avg_energi
FROM streams AS s
INNER JOIN features AS f
ON s.song=f.name
GROUP BY artist
ORDER BY artist ASC;
-- menentukan lagu yang rilis pada tahun 2019 dan tentukan rangkingnya berdasarkan streamers terbanyak
SELECT song,
	ROUND(streams_billion, 2) AS streams,
    RANK() OVER(ORDER BY streams_billion DESC) AS rank_streamers
FROM streams
WHERE release_date LIKE '%-19';
-- membuat field baru dengan nama new_mode yang dimana 1 major dan 0 minor
SELECT name AS song,
	mode,
    CASE WHEN mode = 1 THEN 'major'
		WHEN mode = 0 THEN 'minor'
		ELSE NULL END AS 'new_mode'
FROM features
ORDER BY name ASC;
-- menjumlahkan lagu dengan tangga nada minor dari quaeri sebelumnya
SELECT COUNT(new_mode) AS total_minor
FROM (SELECT name AS song,
	mode,
    CASE WHEN mode = 1 THEN 'major'
		WHEN mode = 0 THEN 'minor'
		ELSE NULL END AS 'new_mode'
	FROM features
	ORDER BY name ASC) AS new_features
WHERE new_mode = 'minor';
-- <0,33 is speech, 0,33-0,66 is speech and music,>0,66 is music
SELECT name AS song,
	ROUND(speechiness, 3) AS speechness,
    CASE WHEN speechiness < 0.33 THEN 'speech'
		WHEN speechiness BETWEEN 0.33 AND 0.66 THEN 'music_and_speech'
        WHEN speechiness > 0.66 THEN 'music'
        ELSE NULL END AS new_speechiness
FROM features
ORDER BY name ASC;
-- menentukan artis yang memiliki speechiness dengan kategori speech paling banyak
with n as (SELECT name AS song,
	ROUND(speechiness, 3) AS speechness,
    CASE WHEN speechiness < 0.33 THEN 'speech'
		WHEN speechiness BETWEEN 0.33 AND 0.66 THEN 'music_and_speech'
        WHEN speechiness > 0.66 THEN 'music'
        ELSE NULL END AS new_speechiness
	FROM features
	ORDER BY name ASC);
INNER JOIN streams AS s
ON n.song=s.song
GROUP BY s.artist ASC, new_speechiness;