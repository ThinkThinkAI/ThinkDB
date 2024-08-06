export async function initializeGrid(gridId) {
  const gridElement = document.getElementById(gridId);

  if (!gridElement) {
    console.warn("Grid element not found!");
    return;
  }

  // Clean up any existing grid instance to avoid multiple instances.
  if (window.gridApi) {
    window.gridApi.destroy();
    window.gridApi = null;
  }

  const columnDefs = [];
  const pageSizeOptions = [15, 30, 40, 50, 100];
  const querySql = "<%= raw sql %>";

  let totalRecords = 0;

  const gridOptions = {
    rowModelType: "infinite",
    columnDefs: columnDefs,
    pagination: true,
    paginationPageSize: 15,
    paginationPageSizeSelector: pageSizeOptions,
    onGridReady: function (event) {
      fetchMetadata(querySql, columnDefs, setGridOptionsCallback);
    },
  };

  window.gridApi = agGrid.createGrid(gridElement, gridOptions);

  function setGridOptionsCallback(updatedColumnDefs, datasource) {
    totalRecords = datasource.rowCount;
    window.gridApi.setGridOption("columnDefs", updatedColumnDefs);
    window.gridApi.setGridOption("datasource", datasource);
  }
}

async function fetchMetadata(querySql, columnDefs, callback) {
  try {
    console.log(querySql);
    const fetchUrl = `/queries/metadata?sql=${encodeURIComponent(querySql)}`;
    const response = await fetch(fetchUrl);
    const data = await response.json();

    if (data.failure) {
      alert(data.failure);
      return;
    }

    data.column_names.forEach((column) => {
      columnDefs.push({ headerName: column, field: column });
    });

    const datasource = createDatasource(data.total_records, querySql);
    callback(columnDefs, datasource);
  } catch (error) {
    console.log("An error occurred while fetching metadata: " + error.message);
  }
}

function createDatasource(totalRecords, querySql) {
  return {
    rowCount: totalRecords,
    getRows: async function (params) {
      try {
        console.log(params);
        const page = Math.floor(params.startRow / params.endRow) + 1;

        let sort_options = "";

        if (params.sortModel.length > 0) {
          sort_options = `&column=${params.sortModel[0].colId}&order=${params.sortModel[0].sort}`;
        }

        let url = `/queries/data?sql=${encodeURIComponent(
          querySql
        )}&page=${page}&results_per_page=${
          params.endRow - params.startRow
        }&${sort_options}`;

        const response = await fetch(url);
        const data = await response.json();

        if (data.failure) {
          params.failCallback();
          return;
        }

        params.successCallback(data, totalRecords);
      } catch (error) {
        params.failCallback();
        console.log("Error while fetching data: " + error.message);
      }
    },
  };
}
