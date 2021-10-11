(********************************)
(* TARGA Loader v0.2 by XProger *)
(* http://XProger.mirgames.ru   *)
(* XProger@list.ru              *)
(********************************)
unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, ExtCtrls, StdCtrls, AppEvnts,
  TARGA;

type
  TForm1 = class(TForm)
    OpenDialog1: TOpenDialog;
    PopupMenu1: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    SaveDialog1: TSaveDialog;
    ScrollBox1: TScrollBox;
    PaintBox1: TPaintBox;
    procedure FormCreate(Sender: TObject);
    procedure N1Click(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

type
 TRGB = array [0..1] of
  record
   B, G, R : Byte;
  end;
 PRGB = ^TRGB;

var
 Form1: TForm1;
 bmp: TBitmap;

implementation

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
begin
 OpenDialog1.InitialDir:=ExtractFilePath(Application.ExeName);
 //
 bmp:= TBitmap.Create;
 bmp.PixelFormat := pf24bit;
end;

procedure TForm1.N1Click(Sender: TObject);
var
 tga    : TGA_Header;
 x, y   : integer;
 d      : PByteArray;
 p      : PRGB;
 k, bpp : integer;
begin
if OpenDialog1.Execute then
 begin
 // Грузим картинку
 try
  tga := LoadTGA(OpenDialog1.FileName);
 except
  tga.Data := nil;
 end;
 // LoadTGA возвращает структуру заголовка файла + данные
 // Если Data = nil значит при загрузке произошла ошибка
 // Иначе в Data хранится указатель на данные изображения
 // размером Width*Height*BPP бит
 if tga.Data <> nil then
  begin
  bmp.Width  := tga.Width;
  bmp.Height := tga.Height;
  // BPP - кол-во бит на пиксель автоматически доводится до 24 - 32 бит
  // даже если изображение было 8 или 16 bpp
  // Данный цикл производит копирование изображения в Bitmap контекст
  d := tga.Data;
  k := 0;
  bpp := tga.BPP div 8;
  for y := 0 to tga.Height - 1 do
   begin
   p := bmp.ScanLine[tga.Height - y - 1];
   for x := 0 to tga.Width - 1 do
    with p[x] do
     begin
     B := d[k];
     G := d[k + 1];
     R := d[k + 2];
     inc(k, bpp);
     end;
   end;
  // Необходимо высвобождаь пямять под загруженное изображение
  FreeMem(tga.Data);
  with PaintBox1 do
   begin
   Width  := bmp.Width;
   Height := bmp.Height;
   Refresh;
   Paint;
   end;
  end
 else
  MessageBox(Handle, 'Ошибка при загрузке TARGA изображения', 'Ошибка', MB_ICONHAND);
 end;
end;

// ScreenShot
procedure TForm1.N2Click(Sender: TObject);
var
 bmp : TBitmap;
 p   : ^TRGB;
 y   : integer;
begin
if SaveDialog1.Execute then
 begin
 bmp             := TBitmap.Create;
 bmp.Width       := GetSystemMetrics(SM_CXSCREEN);
 bmp.Height      := GetSystemMetrics(SM_CYSCREEN);
 bmp.PixelFormat := pf24bit;
 BitBlt(bmp.Canvas.Handle, 0, 0, bmp.Width, bmp.Height, GetDC(0), 0, 0, SRCCOPY);
 GetMem(p, bmp.Width * bmp.Height * 3);
 for y := 0 to bmp.Height - 1 do
  Move(PRGB(bmp.ScanLine[bmp.Height - y - 1])[0],
       p[y*bmp.Width], bmp.Width*3);
 // Только 24 битные несжатые!
 SaveTGA(SaveDialog1.FileName, bmp.Width, bmp.Height, p);
 FreeMem(p);
 bmp.Free;
 end;
end;

procedure TForm1.PaintBox1Paint(Sender: TObject);
begin
 // Перерисовка загруженного рисунка на форме
 PaintBox1.Canvas.Draw(0, 0, bmp);
end;

end.
