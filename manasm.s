  section .data
cztery: dq 4.0

  section .text
  global mandel

  ; dostepne dane funkcji -
  ; rdi - wskaznik na lewy dolny pixel bitmapy
  ; esi - rozmiar bitmapy (bitmapa kwadratowa o dlugosci esi)
  ; xmm0 - delta
  ; xmm1 - Re(p) aka x
  ; xmm2 - Im(p) aka y

mandel:
  push rbp
  mov rbp, rsp
  push rbx

begin:
  ; potrzebne : licznik petli x, licznik petli y, licznik petli k
  ; 6 floatow - origx, oldx, oy, nx, ny, stala 4

  ; licznik petli x - edx
  ; licznik petli y - ecx
  ; licznik petli k - eax
  ; ebx - stala, ilosc iteracji przy sprawdzaniu naleznosci do zbioru mandel
  ; rdi - wskaznik, gdzie aktualnie pisac kolor

  ; xmm3 - stala 4
  ; xmm4 - origx
  ; xmm5 - old x
  ; xmm6 - old y
  ; xmm7 - new x
  ; xmm8 - new y

  movsd xmm3, [cztery] ; stala 4
  movsd xmm4, xmm1 ; oryginalna wartosc x
  mov ebx, 400
  mov rcx, 0
  mov edx, 0
  xorpd xmm5, xmm5
  xorpd xmm6, xmm6
  xorpd xmm8, xmm8
  xorpd xmm9, xmm9

outerloop:
  xor ecx, ecx

innerloop:
  ; petla k sprawdzajaca czy punkt zawiera sie
  xor eax, eax
  xorpd xmm7, xmm7
  xorpd xmm8, xmm8
  xorpd xmm10, xmm10

checkloop:
  ; zastosowane optymalizacje - wykorzystuje fakt,
  ; ze obliczone zostaly w poprzedniej iteracji y^2
  ; i zachowane w xmm10
  movsd xmm5, xmm7 ; oldx = newx
  movsd xmm6, xmm8 ; oldy = newy

  ; movsd xmm7, xmm5 ; newx = oldx
  mulsd xmm7, xmm7 ; newx = oldx^2
  addsd xmm7, xmm1 ; newx = x + oldx^2

  ; movsd xmm8, xmm6 ; newy = oldy
  mulsd xmm8, xmm5 ; newy = oldx*oldy
  addsd xmm8, xmm8 ; newy = 2*(oldx*oldy)
  addsd xmm8, xmm2 ; newy = y + 2*(oldx*oldy)

  ; mulsd xmm6, xmm6 ; oldy = oldy^2
  ; subsd xmm7, xmm6 ; newx = x + oldx^2 - oldy // oldy = oldy^2
  subsd xmm7, xmm10 ; newx = x + oldx^2 - oldy // oldy = oldy^2

  movsd xmm9, xmm7 ; t1 = newx
  movsd xmm10, xmm8 ; t2 = newy

  mulsd xmm9, xmm9 ; t1 = newx^2
  mulsd xmm10, xmm10 ; t2 = newy^2

  addsd xmm9, xmm10 ; t1 = newx^2 + newy^2

  ucomisd xmm9, xmm3 ; |z_n| >? 4.0
  ja nocolor

  ; koniec petli k
  inc eax
  cmp eax, ebx
  jb checkloop
  mov dword [rdi], 255 ; kolor dla punktu nalezacego
  jmp end_y

nocolor:
  mov dword [rdi], 0 ; kolor dla punktu nienalezacego

end_y:
  ; koniec petli y
  inc ecx
  add rdi, 4 ; przesuwam na kolejny pixel
  addsd xmm1, xmm0 ; x += delta
  cmp ecx, esi
  jb innerloop

  movsd xmm1, xmm4 ; nastaw wartosc poczatkowa x
  addsd xmm2, xmm0 ; y += delta

  ; koniec petli x
  inc edx
  cmp edx, esi
  jb outerloop

end:
  pop rbx
  mov rsp, rbp
  pop rbp
  ret
