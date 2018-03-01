class JendelaResep < JendelaAplikasi
	def initialize
		@selesai = false
		@aktif = true
		super("Pembuat Resep", 400, 400, &method(:pengaturan))
		buat_isi
		perbarui until @selesai
	end

	def pengaturan(opsi)
		opsi[:X] = 400
		opsi[:Y] = 200
		opsi[:UbahUkuran] = false
		opsi[:Tombol][:Perbesar] = false
	end

	def buat_isi
		buat_kanvas_pilihan_resep
		buat_kanvas_menu
		buat_tampilan
	end

	def buat_kanvas_pilihan_resep
		@daftar = DaftarResep.new(self)
		@daftar.isi_tutup
		@daftar.isi_buka
	end

	def buat_kanvas_menu
		@menu = []
		@menu << Menu.new(self, panjang - 100, 10, :simpan)
		@menu << Menu.new(self, panjang - 100, 100, :salin)
		@menu << Menu.new(self, panjang - 100, 190, :tambah)
		[:buka, :hapus, :bantuan, :keluar].each_with_index do |v, i|
			@menu << Menu.new(self, panjang - 100, 10 + i * 90, v)
		end
		[:kredit, :versi, :hapus_semua].each_with_index do |v, i|
			@menu << Menu.new(self, 20 + i * 90, 280, v)
		end
	end

	def buat_tampilan
		@tampilan = TampilanResep.new(self)
		@bahan = Daftar_Bahan.new(self)
		@tampilan.kepadatan = 0
	end

	def perbarui
		super
		PapanTik.perbarui
		if @aktif
			@tampilan.perbarui
			@bahan.perbarui
			@daftar.perbarui
			@menu.each(&:perbarui)
		end
	end

	def aktifkan
		@aktif = true
	end

	def nonaktifkan
		@aktif = false
	end

	def refresh_menu
		@menu.each(&:refresh)
	end

	def bahan
		@bahan
	end

	def memilih
		@menu.each do |m|
			m.aktifkan if m.tipe == :hapus || m.tipe == :buka
		end
	end

	def tidak_memilih
		@menu.each do |m|
			m.nonaktifkan if m.tipe == :hapus || m.tipe == :buka
		end
	end

	def tampilkan_bahan
		until @bahan.kelihatan_semua?
			@bahan.ox += 5
			@tampilan.x -= 3
			perbarui
		end
	end

	def hapus_semua
		DataResep.semua_resep.clear
		@daftar.perbarui_resep
		@daftar.refresh_buka
	end

	def resep_bahan(bahan)
		until @bahan.tertutup?
			@bahan.ox -= 5
			@tampilan.x += 3 unless @tampilan.x >= 10
			perbarui
		end
		@tampilan.matikan_mode_memilih_bahan(bahan)
	end

	def pilihan_resep_terbuka?
		@daftar.terbuka?
	end

	def selesai
		@selesai = true
	end

	def tambah_resep
		resep = Resep.new("Resep Baru")
		DataResep.tambah(resep)
		@tampilan.atur_awal(resep)
		tampilkan_resep
	end

	def buka_resep
		@tampilan.atur_awal(@daftar.resep)
		tampilkan_resep
	end

	def hapus_resep
		@daftar.hapus
	end

	def tampilkan_resep
		until @tampilan.kepadatan == 100
			@tampilan.kepadatan += 2
			@daftar.kurangi_kepadatan
			@menu.each { |i| i.kepadatan -= 2 ; i.tutup }
			perbarui
		end
		@menu.each(&:kembali)
	end

	def kembali_menu_awal
		until @tampilan.kepadatan <= 0
			@tampilan.kepadatan -= 2
			@daftar.tambah_kepadatan
			@menu.each { |i| i.kepadatan += 2 }
			perbarui
		end
		@daftar.perbarui_resep
	end
end