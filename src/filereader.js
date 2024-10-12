// Helpers to convert a drop of a directory of files into a list of
// [ {path: "/dir/file.ext", file:  ...}, ...]


// 'promisify' readEntries
// https://developer.mozilla.org/en-US/docs/Web/API/FileSystemDirectoryEntry/createReader
export async function readDirectory(directory) {
    const dirReader = directory.createReader();
    const entries = [];

    while (true) {
        const results = await new Promise((resolve, reject) => {
            dirReader.readEntries(resolve, reject);
        });

        if (!results.length) {
            break;
        }

        for (const entry of results) {
            let x = await convert(entry, directory.fullPath)
            entries.push(x);
        }
    }

    return entries;
}

export function convert(item, path) {
    return new Promise((resolve, reject) => {
        path = path || "";
        if (item.isFile) {
            // Get file (as promise)
            item.file((file) => {
                const fullPath = `${path}/${file.name}`
                // console.log(`File: ${fullPath}`, file);
                return resolve({path: fullPath, file})
            });
        } else if (item.isDirectory) {
            // Get folder contents
            // console.log("Dir:", item.fullPath);
            return readDirectory(item).then(dir => resolve(dir.flat())).catch(reject);
        }
    })
}

export function convertItems(items) {
    let results = []
    for (let i = 0; i < items.length; i++) {
        // read each entry from the dropped data
        let entry = items[i].webkitGetAsEntry();
        // [{file, path: "/files/test.png}]
        results.push(convert(entry))
    }
    return Promise.all(results)
}