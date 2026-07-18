// Repackages an exploded plugin jar directory into a jar that IntelliJ's
// memory-mapped ImmutableZipFile reader accepts. Unlike .NET's ZipFile, this
// writes no NTFS/Unicode extra fields, which is what tripped the platform
// reader. Run with the product's own runtime, no compile step required:
//   jbr\bin\java.exe scripts\PluginRepack.java <sourceDir> <outputJar>
import java.io.IOException;
import java.io.OutputStream;
import java.nio.file.*;
import java.nio.file.attribute.BasicFileAttributes;
import java.util.zip.CRC32;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;

public class PluginRepack {
  public static void main(String[] args) throws IOException {
    if (args.length != 2) {
      System.err.println("usage: PluginRepack <sourceDir> <outputJar>");
      System.exit(2);
    }
    Path src = Paths.get(args[0]).toAbsolutePath().normalize();
    Path out = Paths.get(args[1]).toAbsolutePath().normalize();
    Files.createDirectories(out.getParent());
    try (OutputStream os = Files.newOutputStream(out);
         ZipOutputStream zos = new ZipOutputStream(os)) {
      zos.setMethod(ZipOutputStream.DEFLATED);
      Files.walkFileTree(src, new SimpleFileVisitor<Path>() {
        @Override public FileVisitResult visitFile(Path file, BasicFileAttributes attrs) throws IOException {
          String name = src.relativize(file).toString().replace('\\', '/');
          byte[] data = Files.readAllBytes(file);
          ZipEntry e = new ZipEntry(name);
          e.setTime(0L);
          CRC32 crc = new CRC32();
          crc.update(data);
          e.setCrc(crc.getValue());
          zos.putNextEntry(e);
          zos.write(data);
          zos.closeEntry();
          return FileVisitResult.CONTINUE;
        }
      });
    }
    System.out.println("repacked -> " + out);
  }
}
