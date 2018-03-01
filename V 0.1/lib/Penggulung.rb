class Penggulung < Kanvas
	def initialize(konten, lebar = nil)
		super(konten.jendela, 0, 0, 20, lebar || konten.ol)
		@konten = konten
		ganti_posisi
		posisi_tombol
		refresh
	end

	def gulung_max
		@dasar.lebar - @batang_gulung.lebar + panjang + 5
	end

	def paling_atas?
		@batang_gulung.y <= panjang + 5
	end

	def paling_bawah?
		@batang_gulung.y >= gulung_max
	end

	def diatas_kursor?
		kursor = kursor()
		return !kursor.nil? && (kursor.x.between?(x, x + panjang) && kursor.y.between?(y, x + lebar))
	end

	def objek_diatas_kursor?(objek)
		kursor = kursor()
		return diatas_kursor? && (kursor.x.between?(objek.x + x, objek.x + objek.panjang + x) && kursor.y.between?(objek.y + y, objek.y + objek.lebar + y))
	end

	def ganti_posisi
		self.x = @konten.x + @konten.op + 5
		self.y = @konten.y
	end

	def posisi_tombol
		@dasar = Area.new(0, panjang + 5, panjang, lebar - (panjang + 5) * 2)
		@atas = Area.new(0, 0, panjang, panjang)
		@bawah = Area.new(0, lebar - panjang, panjang, panjang)
		@batang_gulung = Area.new(1, panjang + 5, panjang - 2, ((@konten.ol.to_f / @konten.lebar) * (lebar - (panjang + 6) * 2)).to_i)
	end

	def perbarui
		super
		y_gulung = panjang + 6 + (@konten.oy == 0 ? 0 : (@konten.oy.to_f / @konten.lebar) * (lebar - (panjang + 6) * 2))
		refresh if @batang_gulung.y != y_gulung || @akhir
		masukan
		@akhir = diatas_kursor?
	end

	def gulungan
		gulung_y = panjang + 6 + (@konten.oy == 0 ? 0 : (@konten.oy.to_f / @konten.lebar) * (lebar - (panjang + 6) * 2))
		@batang_gulung.y = gulung_y.to_i
	end

	def tampilkan_gambar
		daftar_warna = kalkulasi_warna
		warnai_area(@atas, daftar_warna[0])
		warnai_area(@bawah, daftar_warna[1])
		unless paling_atas? || paling_bawah?
			warnai_area(@dasar, daftar_warna[2])
			warnai_area(@batang_gulung, daftar_warna[3])
		end
		garis((@atas.panjang / 3.0).to_i, (@atas.lebar * 2 / 3.0).to_i, (@atas.panjang / 2.0).to_i, (@atas.lebar / 3.0).to_i, Warna.new(0, 0, 0))
		garis((@atas.panjang * 2 / 3.0).to_i, (@atas.lebar * 2 / 3.0).to_i, (@atas.panjang / 2.0).to_i, (@atas.lebar / 3.0).to_i, Warna.new(0, 0, 0))
		garis((@bawah.panjang / 3.0).to_i + @bawah.x, (@bawah.lebar / 3.0).to_i + @bawah.y, (@bawah.panjang / 2.0).to_i + @bawah.x, (@bawah.lebar * 2 / 3.0).to_i + @bawah.y, Warna.new(0, 0, 0))
		garis((@bawah.panjang * 2 / 3.0).to_i + @bawah.x, (@bawah.lebar / 3.0).to_i + @bawah.y, (@bawah.panjang / 2.0).to_i + @bawah.x, (@bawah.lebar * 2 / 3.0).to_i + @bawah.y, Warna.new(0, 0, 0))
	end

	def kalkulasi_warna
		warna = [Warna.new(200, 199, 210), Warna.new(200, 199, 210), Warna.new(210, 220, 220), Warna.new(180, 170, 190)]
		tambahan = [
			!objek_diatas_kursor?(@atas) ? 0 : Mouse.menekan? ? 20 : -10,
			!objek_diatas_kursor?(@bawah) ? 0 : Mouse.menekan? ? 20 : -10,
			0,
			!objek_diatas_kursor?(@batang_gulung) ? 0 : Mouse.menekan? ? 20 : -10
		]
		warna.each_with_index do |v, i|
			v.merah += tambahan[i]
			v.hijau += tambahan[i]
			v.biru += tambahan[i]
		end
	end

	def refresh
		gulungan
		tampilkan_gambar
	end

	def masukan
		return unless diatas_kursor? && Mouse.menekan?
		@konten.oy -= 1 if objek_diatas_kursor?(@atas) && @konten.oy > 0
		@konten.oy += 1 if objek_diatas_kursor?(@bawah) && @konten.oy < @konten.lebar - @konten.ol

		if objek_diatas_kursor?(@batang_gulung)
			@batang_gulung.y = kursor.y - y - panjang - 6 - @batang_gulung.lebar / 2
			kov = (@batang_gulung.y.to_f * @konten.lebar / (lebar - (panjang + 6) * 2)).to_i
			@konten.oy = kov unless kov < 0 || kov > @konten.lebar - @konten.ol
		end
	end
end