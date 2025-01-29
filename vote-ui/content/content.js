const { ref, onMounted } = Vue;

// Define a link towards result UI
const getResultLink = () => {
  const protocol = window.location.protocol;
  const host = window.location.hostname;
  let port = window.location.port;

  // If a port is specified, increment it by 1 for the result link
  if (port) {
    port = parseInt(port) + 1;
    return `${protocol}//${host}:${port}`;
  } 
  // If no port is specified, change the subdomain for the result one
  else {
    const parts = host.split('.');
    
    // Check if the subdomain starts with 'vote-'
    if (parts[0].startsWith('vote-')) {
      // Replace 'vote-' with 'result-' in the subdomain
      parts[0] = parts[0].replace(/^vote-/, 'result-');
    } else if (parts[0] === 'vote') {
      // If it's exactly 'vote', replace it with 'result'
      parts[0] = 'result';
    }
    
    return `${protocol}//${parts.join('.')}`;
  }
};

const template = `
    <div id="content-container">
      <div id="content-container-center">
        <h2>Vote for your favorite!</h2>

        <form id="choice" name="form" @submit.prevent.default>
          <button id="a"
            @click="select('a')" :class="['a', { 'opacity-unselected': current_vote === 'b' }]"
            :disabled="current_vote === 'a'"
            value="a">

              <!-- Conditionally render the image or label for option A -->
              <div v-if="imageAUrl && isImageAValid">
                <img :src="imageAUrl" alt="Image A" @error="onImageError('a')">
              </div>
              <span class="button-text" v-else>{{labelA}}</span>

          </button>

          <button id="b"
            @click="select('b')"
            :disabled="current_vote === 'b'"
            :class="['b', { 'opacity-unselected': current_vote === 'a' }]"
            value="b">

              <!-- Conditionally render the image or label for option B -->
              <div v-if="imageBUrl && isImageBValid">
                <img :src="imageBUrl" alt="Image B" @error="onImageError('b')">
              </div>
              <span class="button-text" v-else>{{labelB}}</span>

          </button>

        </form>

        <div id="resultLink">
          <a :href="resultLink" target="_blank" rel="noopener noreferrer">View Result</a>
        </div>
        
        <div id="hostname" v-if="hostname !== ''">
          Handled by container {{hostname}}
        </div>

        <div id="backend" v-if="backend === 'NATS'">
          <img src="./images/nats.png" height="25"/>
        </div>

      </div>

      <!-- Conditionally render the credits image -->
      <div id="credits" v-if="creditsImageUrl && isCreditsImageUrlValid">
        <a :href="creditsLink" target="_blank" rel="noopener noreferrer">
          <img :src="creditsImageUrl" alt="credits" @error="onImageError('credits')" height="30"/>
        </a>
      </div>

    </div>
`;

export default {
  template,
  setup() {
    const hostname = ref('');
    const voter_id = ref('');
    const backend = ref('');
    const current_vote = ref('');
    const resultLink = getResultLink();

    // Ref for images and labels
    const imageAUrl = ref('');
    const imageBUrl = ref('');
    const isImageAValid = ref(true);
    const isImageBValid = ref(true);
    const labelA = ref('Cats');  // Default label
    const labelB = ref('Dogs');  // Default label

    // Credits related
    const creditsImageUrl = ref('');
    const creditsLink = ref('');
    const isCreditsImageUrlValid = ref(true);

    // Function to fetch the config.json and update image base URL
    const loadConfig = async () => {
      try {
        const response = await fetch('/config/config.json');
        const config = await response.json();
        console.log('Config loaded:', config);

        // Handle images if provided
        if (config.images) {
          imageAUrl.value = config.images.a || '';
          imageBUrl.value = config.images.b || '';
          if (imageAUrl.value) checkImageExists(imageAUrl.value, 'a');
          if (imageBUrl.value) checkImageExists(imageBUrl.value, 'b');
        } else {
          console.log("image URLs not provided");
        }

        // Handle credits image if provided
        if(config.credits.imageURL) {
          creditsLink.value = config.credits.link || '';
          creditsImageUrl.value = config.credits.imageURL || '';
          checkImageExists(creditsImageUrl.value, 'credits');
        } else {
          console.log("No credits image provided");
        }

        // Handle labels if provided
        if (config.labels) {
          labelA.value = config.labels.a || 'Cats';
          labelB.value = config.labels.b || 'Dogs';
          console.log('Labels:', labelA.value, labelB.value);
        } else {
          console.log("labels not provided");
        }

        console.log('Values (after setting):', {
          labelA: labelA.value,
          labelB: labelB.value,
          imageAUrl: imageAUrl.value,
          imageBUrl: imageBUrl.value
        });
      } catch (error) {
        console.error("Error loading config:", error);

        console.log('Values that will be used:', {
          labelA: labelA.value,
          labelB: labelB.value,
          imageAUrl: imageAUrl.value,
          imageBUrl: imageBUrl.value
        });
      }
    };

    // Function to check if an image exists using Image object
    const checkImageExists = (url, type) => {
      if (!url) return;

      const img = new Image();
      
      img.onload = () => {
        console.log(`${type} image exists`);
        if (type === 'a') {
          isImageAValid.value = true;
          console.log(`image valid for type a`);
        } else if (type === 'b') {
          isImageBValid.value = true;
          console.log(`image valid for type b`);
        } else if  (type === 'credits') {
          isCreditsImageUrlValid.value = true;
          console.log(`image valid for credits`);
        } else {
          console.log(`type ${type} no taken into account`);
        }
      };

      img.onerror = () => {
        console.log(`error loading image for type ${type}`);
        onImageError(type);
      };

      img.src = url; // This triggers the image load
    };

    // Handle image loading error
    const onImageError = (type) => {
      console.log(`Error loading ${type} image`);
      if (type === 'a') {
        isImageAValid.value = false;
      } else if (type === 'b') {
        isImageBValid.value = false;
      } else if (type === 'credits') {
        isCreditsImageUrlValid.value = false;
      }
    };

    // Select method for handling voting
    const select = (vote) => {
      console.log("SELECTION DONE");
      current_vote.value = vote;

      fetch('/api/', {
        method: 'post',
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({ vote, voter_id: voter_id.value }),
      }).then(function (res) {
        return res.json();
      }).then(function (res) {
        console.log(res);
        hostname.value = res.hostname;
        voter_id.value = res.voter_id;
        backend.value = res.backend;
      })
    }

    // Trigger config loading and image existence check on component mount
    onMounted(() => {
      loadConfig();
    });

    return {
      hostname,
      backend,
      select,
      current_vote,
      resultLink,
      creditsImageUrl,
      creditsLink,
      isCreditsImageUrlValid,
      imageAUrl,
      imageBUrl,
      isImageAValid,
      isImageBValid,
      labelA,
      labelB,
      onImageError
    }
  }
}
