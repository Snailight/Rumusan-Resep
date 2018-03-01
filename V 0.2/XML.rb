module XML
	JENIS_XML = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"


	PARAGRAF_RESEP = "\t".freeze
	PARAGRAF_BAHAN = "\t\t".freeze

	REGEXP_DITERIMA_DAFTAR = /\n\t\>\<\w\/\s\"\=/
	REGEXP_DITERIMA_NAMA = /\w\-\_ /
	REGEXP_DITERIMA_RESEP = /\<resep nama\=\"([#{REGEXP_DITERIMA_NAMA}]+)\" bahan\=\"\d+\" \>/
	REGEXP_DITERIMA_RESEP_KOSONG = /\<resep nama\=\"([#{REGEXP_DITERIMA_NAMA}]+)\" bahan\=\"0\" \/\>/
	REGEXP_DITERIMA_BAHAN = /\<bahan nama=\"([#{REGEXP_DITERIMA_NAMA}]+)\" banyak=\"(\d+)\" \/\>/
	REGEXP_DITERIMA_AKHIR_RESEP = /\<\/resep\>/
end

load "XML_tulis.rb"
load "XML_baca.rb"