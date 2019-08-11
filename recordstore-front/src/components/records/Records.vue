<template>
  <div class="max-w-md m-auto py-10">
    <div class="text-red" v-if="error">{{ error }}</div>
    <h3 class="font-mono font-regular text-3xl mb-4">Add a new record</h3>

    <form @submit.prevent="addRecord">
      <div class="mb-6">
        <label for="record_title" class="label">Title</label>
        <input
          type="text"
          id="record_title"
          class="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline"
          autofocus
          autocomplete="off"
          placeholder="Type a record name"
          v-model="newRecord.title">
      </div>

      <div class="mb-6">
        <label for="record_year" class="label">Year</label>
        <input
          type="text"
          id="record_year"
          class="shadow appearance-none border border-red-500 rounded w-full py-2 px-3 text-gray-700 mb-3 leading-tight focus:outline-none focus:shadow-outline"
          autofocus
          autocomplete="off"
          placeholder="Year"
          v-model="newRecord.year">
      </div>

      <div class="mb-6">
        <label for="artist" class="label">Artist</label>
        <select id="artist"
                class="block appearance-none w-full bg-white border border-gray-400 hover:border-gray-500 px-4 py-2 pr-8 rounded shadow leading-tight focus:outline-none focus:shadow-outline"
                v-model="newRecord.artist">
          <option disabled value="">Select an artist</option>
          <option :value="artist.id" v-for="artist in artists" :key="artist.id">{{ artist.name }}</option>
        </select>
        <p class="pt-4">Don't see an artist? <router-link to="/artists" class="inline-block align-baseline font-bold text-sm text-blue-500 hover:text-blue-800">Create one</router-link></p>
      </div>

      <input type="submit" value="Add Record" class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded focus:outline-none focus:shadow-outline">
    </form>

    <hr class="border border-grey-light my-6" />

    <ul class="list-reset mt-4">
      <li class="py-4" v-for="record in records" :key="record.id" :record="record">
        <div class="flex items-center justify-between flex-wrap">
          <div class="flex-1 flex justify-between flex-wrap pr-4">
          <p class="block flex font-mono font-semibold flex items-center">
            <svg class="fill-current text-indigo w-6 h-6 mr-2" viewBox="0 0 24 24" width="24" height="24"><title>record vinyl</title><path d="M23.938 10.773a11.915 11.915 0 0 0-2.333-5.944 12.118 12.118 0 0 0-1.12-1.314A11.962 11.962 0 0 0 12 0C5.373 0 0 5.373 0 12s5.373 12 12 12 12-5.373 12-12c0-.414-.021-.823-.062-1.227zM12 16a4 4 0 1 1 0-8 4 4 0 0 1 0 8zm0-5a1 1 0 1 0 0 2 1 1 0 0 0 0-2z" ></path></svg>
            {{ record.title }} &mdash; {{ record.year }}
          </p>
          <p class="block font-mono font-semibold">{{ getArtist(record) }}</p>
        </div>

        <button class="bg-transparent text-sm hover:bg-blue hover:text-white text-blue border border-blue no-underline font-bold py-2 px-4 mr-2 rounded"
          @click.prevent="editRecord(record)">Edit</button>

        <button class="bg-transparent text-sm hover:bg-red text-red hover:text-white no-underline font-bold py-2 px-4 rounded border border-red"
         @click.prevent="removeRecord(record)">Delete</button>
        </div>

        <div v-if="record == editedRecord">
          <form action="" @submit.prevent="updateRecord(record)">
            <div class="mb-6 p-4 bg-white rounded border border-grey-light mt-4">

              <div class="mb-6">
                <label class="label">Title</label>
                <input class="input" v-model="record.title">
              </div>

              <div class="mb-6">
                <label class="label">Year</label>
                <input class="input" v-model="record.year">
              </div>

              <div class="mb-6">
                 <select id="artist_update" class="select" v-model="record.artist">
                    <option disabled value="">Select an artist</option>
                  <option :value="artist.id" v-for="artist in artists" :key="artist.id">{{ artist.name }}</option>
                  </select>
              </div>

              <input type="submit" value="Update" class="bg-transparent text-sm hover:bg-blue hover:text-white text-blue border border-blue no-underline font-bold py-2 px-4 mr-2 rounded">
            </div>
          </form>
        </div>
      </li>
    </ul>
  </div>
</template>

<script>
export default {
  name: 'Records',
  data () {
    return {
      artists: [],
      records: [],
      newRecord: [],
      error: '',
      editedRecord: ''
    }
  },
  created () {
    if (!localStorage.signedIn) {
      this.$router.replace('/')
    } else {
      this.$http.secured.get('/api/v1/records')
        .then(response => { this.records = response.data })
        .catch(error => this.setError(error, 'Something went wrong'))

      this.$http.secured.get('/api/v1/artists')
        .then(response => { this.artists = response.data })
        .catch(error => this.setError(error, 'Something went wrong'))
    }
  },
  methods: {
    setError (error, text) {
      this.error = (error.response && error.response.data && error.response.data.error) || text
    },
    getArtist (record) {
      const recordArtistValues = this.artists.filter(artist => artist.id === record.artist_id)
      let artist

      recordArtistValues.forEach(function (element) {
        artist = element.name
      })

      return artist
    },
    addRecord () {
      const value = this.newRecord
      if (!value) {
        return
      }
      this.$http.secured.post('/api/v1/records/', { record: { title: this.newRecord.title, year: this.newRecord.year, artist_id: this.newRecord.artist } })

        .then(response => {
          this.records.push(response.data)
          this.newRecord = ''
        })
        .catch(error => this.setError(error, 'Cannot create record'))
    },
    removeRecord (record) {
      this.$http.secured.delete(`/api/v1/records/${record.id}`)
        .then(response => {
          this.records.splice(this.records.indexOf(record), 1)
        })
        .catch(error => this.setError(error, 'Cannot delete record'))
    },
    editRecord (record) {
      this.editedRecord = record
    },
    updateRecord (record) {
      this.editedRecord = ''
      this.$http.secured.patch(`/api/v1/records/${record.id}`, { record: { title: record.title, year: record.year, artist_id: record.artist } })
        .catch(error => this.setError(error, 'Cannot update record'))
    }
  }
}
</script>
